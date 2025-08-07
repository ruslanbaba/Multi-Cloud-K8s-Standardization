describe('Deployments', () => {
  beforeEach(() => {
    cy.login();
    cy.visit('/deployments');
  });

  it('should list all deployments', () => {
    cy.get('[data-testid=deployment-list]')
      .should('be.visible')
      .find('[data-testid=deployment-item]')
      .should('have.length.gt', 0);
  });

  it('should create new deployment from template', () => {
    cy.get('[data-testid=create-deployment-button]').click();
    cy.get('[data-testid=template-select]').click().type('nginx{enter}');
    cy.get('[data-testid=cluster-select]').click().type('production-cluster{enter}');
    cy.get('[data-testid=namespace-input]').type('test-app');
    cy.get('[data-testid=replicas-input]').clear().type('3');
    cy.get('[data-testid=submit-button]').click();

    cy.get('[data-testid=success-message]')
      .should('be.visible')
      .and('contain', 'Deployment created successfully');
  });

  it('should update existing deployment', () => {
    cy.get('[data-testid=deployment-item]').first().click();
    cy.get('[data-testid=edit-button]').click();
    cy.get('[data-testid=replicas-input]').clear().type('5');
    cy.get('[data-testid=update-button]').click();

    cy.get('[data-testid=success-message]')
      .should('be.visible')
      .and('contain', 'Deployment updated successfully');
  });

  it('should show deployment logs', () => {
    cy.get('[data-testid=deployment-item]').first().click();
    cy.get('[data-testid=logs-tab]').click();
    cy.get('[data-testid=log-viewer]')
      .should('be.visible')
      .and('not.be.empty');
  });

  it('should show deployment metrics', () => {
    cy.get('[data-testid=deployment-item]').first().click();
    cy.get('[data-testid=metrics-tab]').click();
    
    cy.get('[data-testid=resource-usage-chart]').should('be.visible');
    cy.get('[data-testid=request-rate-chart]').should('be.visible');
    cy.get('[data-testid=error-rate-chart]').should('be.visible');
  });
});
