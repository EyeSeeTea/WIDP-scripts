Steps:
1. Add new orgUnitTree under NA region
2. Reassign data for mapped OU
	Reassign data but also all the references for the mapped OU like references in charts, in OU groups, or in users.
	Normally, only OU with data will have such kind of important references.
3. Relocate OUs to keep
	A mapping with the parent should be provided for the OU we want to keep that does not exist in the new OU.
4. Delete all assignments to orgUnits (programs, ds, groups...) and old Tree (except the root (country))
5. reassing childs of new country to old (root) country
	keep in mind we want to keep the old WIDP country OU, so we move the childs from new ouTree to old country OU
6. delete new OU country (only the root)