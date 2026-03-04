const API_URL = "http://localhost:4567/tarefas";

// Carregar tarefas ao iniciar
document.addEventListener("DOMContentLoaded", loadTasks);

// Adicionar nova tarefa
document.getElementById("formAdd").addEventListener("submit", async (e) => {
  e.preventDefault();

  const taskData = {
    responsible: document.getElementById("newResponsible").value,
    task: document.getElementById("newTask").value,
    priority: parseInt(document.getElementById("newPriority").value),
  };

  try {
    const response = await fetch(API_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(taskData),
    });

    if (response.ok) {
      showMessage("Tarefa adicionada com sucesso!", "success");
      document.getElementById("formAdd").reset();
      loadTasks();
    } else {
      const error = await response.json();
      showMessage(error.error || "Erro ao adicionar tarefa", "error");
    }
  } catch (error) {
    showMessage("Erro de conexão com o servidor", "error");
  }
});

// Carregar todas as tarefas
async function loadTasks() {
  try {
    const response = await fetch(API_URL);
    const tasks = await response.json();

    renderTasks(tasks);
  } catch (error) {
    document.getElementById("taskTable").innerHTML =
      '<tr><td colspan="4" style="color: red; text-align: center;">Erro ao carregar tarefas</td></tr>';
  }
}

// Renderizar tarefas na tabela
function renderTasks(tasks) {
  const tbody = document.getElementById("taskTable");

  if (tasks.length === 0) {
    tbody.innerHTML =
      '<tr><td colspan="4" style="text-align: center;">Nenhuma tarefa cadastrada</td></tr>';
    return;
  }

  tbody.innerHTML = tasks
    .map(
      (task) => `
    <tr data-id="${task.id}">
        <td class="responsible">${escapeHtml(task.responsible)}</td>
        <td class="task">${escapeHtml(task.task)}</td>
        <td class="priority ${getPriorityClass(task.priority)}">${task.priority}</td>
        <td class="actions">
            <button class="btn btn-edit" onclick="editTask(${task.id})">Editar</button>
            <button class="btn btn-delete" onclick="deleteTask(${task.id})">Excluir</button>
        </td>
    </tr>
`,
    )
    .join("");
}

// Editar tarefa
async function editTask(id) {
  const row = document.querySelector(`tr[data-id="${id}"]`);
  const responsibleCell = row.querySelector(".responsible");
  const taskCell = row.querySelector(".task");
  const priorityCell = row.querySelector(".priority");
  const actionsCell = row.querySelector(".actions");

  // Salvar valores originais
  const originalResponsible = responsibleCell.textContent;
  const originalTask = taskCell.textContent;
  const originalPriority = priorityCell.textContent;

  // Criar inputs de edição
  responsibleCell.innerHTML = `<input type="text" class="edit-input" value="${escapeHtml(originalResponsible)}" maxlength="30">`;
  taskCell.innerHTML = `<input type="text" class="edit-input" value="${escapeHtml(originalTask)}" maxlength="60">`;
  priorityCell.innerHTML = `<input type="number" class="edit-input" value="${originalPriority}" min="1" max="10">`;

  actionsCell.innerHTML = `
    <button class="btn btn-save" onclick="saveTask(${id})">Salvar</button>
    <button class="btn btn-cancel" onclick="cancelEdit(${id}, '${escapeHtml(originalResponsible)}', '${escapeHtml(originalTask)}', '${originalPriority}')">Cancelar</button>
`;
}

// Salvar edição
async function saveTask(id) {
  const row = document.querySelector(`tr[data-id="${id}"]`);
  const updatedData = {
    responsible: row.querySelector(".responsible input").value,
    task: row.querySelector(".task input").value,
    priority: parseInt(row.querySelector(".priority input").value),
  };

  try {
    const response = await fetch(`${API_URL}/${id}`, {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(updatedData),
    });

    if (response.ok) {
      showMessage("Tarefa atualizada com sucesso!", "success");
      loadTasks();
    } else {
      const error = await response.json();
      showMessage(error.error || "Erro ao atualizar tarefa", "error");
    }
  } catch (error) {
    showMessage("Erro de conexão com o servidor", "error");
  }
}

// Cancelar edição
function cancelEdit(id, responsible, task, priority) {
  const row = document.querySelector(`tr[data-id="${id}"]`);
  row.querySelector(".responsible").textContent = responsible;
  row.querySelector(".task").textContent = task;
  row.querySelector(".priority").textContent = priority;
  row.querySelector(".priority").className =
    `priority ${getPriorityClass(priority)}`;
  row.querySelector(".actions").innerHTML = `
    <button class="btn btn-edit" onclick="editTask(${id})">Editar</button>
    <button class="btn btn-delete" onclick="deleteTask(${id})">Excluir</button>
`;
}

// Deletar tarefa
async function deleteTask(id) {
  if (!confirm("Tem certeza que deseja excluir esta tarefa?")) {
    return;
  }

  try {
    const response = await fetch(`${API_URL}/${id}`, {
      method: "DELETE",
    });

    if (response.ok || response.status === 204) {
      showMessage("Tarefa excluída com sucesso!", "success");
      loadTasks();
    } else if (response.status === 404) {
      showMessage("Tarefa não encontrada", "error");
    } else {
      showMessage("Erro ao excluir tarefa", "error");
    }
  } catch (error) {
    showMessage("Erro de conexão com o servidor", "error");
  }
}

// Mostrar mensagem
function showMessage(text, type) {
  const messageDiv = document.getElementById("message");
  messageDiv.textContent = text;
  messageDiv.className = `message ${type}`;

  setTimeout(() => {
    messageDiv.className = "message";
  }, 3000);
}

// Classe de prioridade para cores
function getPriorityClass(priority) {
  if (priority >= 5) return "priority-high";
  if (priority >= 3) return "priority-medium";
  return "priority-low";
}

// Escape HTML para prevenir XSS
function escapeHtml(text) {
  const div = document.createElement("div");
  div.textContent = text;
  return div.innerHTML;
}
