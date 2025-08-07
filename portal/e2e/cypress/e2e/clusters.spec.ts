describe('Cluster Management', () => {
  beforeEach(() => {
    cy.login(); // Custom command to handle authentication
    cy.visit('/clusters');
  });

  it('should list all clusters', () => {
    cy.get('[data-testid=cluster-list]')
      .should('be.visible')
      .and('have.length.gt', 0);
  });

  it('should show cluster details', () => {
    cy.get('[data-testid=cluster-item]').first().click();
    cy.get('[data-testid=cluster-details]').should('be.visible');
    cy.get('[data-testid=cluster-metrics]').should('be.visible');
  });

  it('should create new cluster', () => {
    cy.get('[data-testid=create-cluster-button]').click();
    cy.get('[data-testid=cloud-provider-select]').click().type('AWS{enter}');
    cy.get('[data-testid=region-select]').click().type('us-west-2{enter}');
    cy.get('[data-testid=node-count-input]').clear().type('3');
    cy.get('[data-testid=submit-button]').click();

    cy.get('[data-testid=success-message]')
      .should('be.visible')
      .and('contain', 'Cluster creation initiated');
  });

  it('should show cluster metrics', () => {
    cy.get('[data-testid=cluster-item]').first().click();
    cy.get('[data-testid=metrics-tab]').click();
    
    cy.get('[data-testid=cpu-usage-chart]').should('be.visible');
    cy.get('[data-testid=memory-usage-chart]').should('be.visible');
    cy.get('[data-testid=pod-count-chart]').should('be.visible');
  });
});
