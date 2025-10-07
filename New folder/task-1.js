 const form = document.getElementById("registerForm");
    const tableBody = document.querySelector("#usersTable tbody");
    const apiUrl = "https://680a5916d5075a76d987b60f.mockapi.io/api/v1/users";

    function clearErrors() {
      document.querySelectorAll(".error").forEach(e => e.innerText = "");
    }

    async function loadUsers() {
      tableBody.innerHTML = "";
      try {
        const res = await fetch(apiUrl);
        const users = await res.json();
        users.forEach(user => {
          tableBody.innerHTML += `
            <tr>
              <td>${user.id}</td>
              <td>${user.name}</td>
              <td>${user.email}</td>
            </tr>
          `;
        });
      } catch (err) {
        tableBody.innerHTML = `<tr><td colspan="3">Error loading users ❌</td></tr>`;
      }
    }

    form.onsubmit = async function (e) {
      e.preventDefault();
      clearErrors();
      let isValid = true;

      const name = document.getElementById("name").value.trim();
      const email = document.getElementById("email").value.trim();
      const password = document.getElementById("password").value;
      const confirmPassword = document.getElementById("confirmPassword").value;

      // Validation
      if (name === "") {
        document.getElementById("name-error").innerText = "Name is required";
        isValid = false;
      } else if (!/^[a-zA-Z ]{3,20}$/.test(name)) {
        document.getElementById("name-error").innerText = "Invalid name";
        isValid = false;
      }

      if (email === "") {
        document.getElementById("email-error").innerText = "Email is required";
        isValid = false;
      } else if (!/^[a-zA-Z0-9._]+@[a-z]+\.[a-z]{2,}$/.test(email)) {
        document.getElementById("email-error").innerText = "Invalid email";
        isValid = false;
      }

      if (password === "") {
        document.getElementById("password-error").innerText = "Password is required";
        isValid = false;
      } else if (!/^(?=.*[A-Z])(?=.*\d).{6,}$/.test(password)) {
        document.getElementById("password-error").innerText =
          "At least 6 chars, 1 uppercase & 1 number";
        isValid = false;
      }

      if (confirmPassword !== password) {
        document.getElementById("confirmPassword-error").innerText = "Passwords do not match";
        isValid = false;
      }

      if (isValid) {
        try {
          const response = await fetch(apiUrl, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ name, email, password })
          });

          if (response.ok) {
            document.getElementById("result").innerHTML =
              "<span class='success'>Registration successful ✅</span>";
            loadUsers(); // reload table
            form.reset(); // clear form
          } else {
            document.getElementById("result").innerHTML =
              "<span class='error'>API Error ❌</span>";
          }
        } catch (err) {
          document.getElementById("result").innerHTML =
            "<span class='error'>Network Error ❌</span>";
        }
      }
    };

    // Load users when page starts
    loadUsers();
  