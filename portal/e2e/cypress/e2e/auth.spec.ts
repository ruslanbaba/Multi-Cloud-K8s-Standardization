describe('Authentication', () => {
  beforeEach(() => {
    cy.visit('/login');
  });

  it('should successfully log in with valid credentials', () => {
    cy.get('[data-testid=email-input]').type('admin@example.com');
    cy.get('[data-testid=password-input]').type('admin123');
    cy.get('[data-testid=login-button]').click();
    
    cy.url().should('eq', `${Cypress.config().baseUrl}/dashboard`);
    cy.get('[data-testid=user-menu]').should('be.visible');
  });

  it('should show error with invalid credentials', () => {
    cy.get('[data-testid=email-input]').type('wrong@example.com');
    cy.get('[data-testid=password-input]').type('wrong123');
    cy.get('[data-testid=login-button]').click();
    
    cy.get('[data-testid=error-message]')
      .should('be.visible')
      .and('contain', 'Invalid credentials');
  });

  it('should redirect to login when accessing protected route', () => {
    cy.visit('/dashboard');
    cy.url().should('include', '/login');
  });
});
