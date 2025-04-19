import "./test.css";

export default function Page() {
  return (
    <div className="login-page">
      <div className="container">
        <h1 className="title">Login</h1>
        <form>
          <div className="form-group">
            <label htmlFor="username">Username</label>
            <input type="text" id="username" name="username" />
          </div>
          <div className="form-group">
            <label htmlFor="password">Password</label>
            <input type="password" id="password" name="password" />
          </div>
          <button type="submit" className="button">Login</button>
        </form>
      </div>
    </div>
  );
}
