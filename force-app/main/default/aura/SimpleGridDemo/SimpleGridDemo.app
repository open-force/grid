<aura:application extends="force:slds">

	<c:Grid>
		<aura:set attribute="columns">

			<c:Column label="Record Id">

				Id:
				<lightning:formattedNumber value="{#record.id}" />

			</c:Column>

			<c:Column label="Record Name">

				Name: {#record.name}

			</c:Column>

		</aura:set>
	</c:Grid>

</aura:application>