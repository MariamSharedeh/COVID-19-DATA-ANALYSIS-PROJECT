Procédure complète : importer un fichier Excel (.xlsx) dans SQL Server avec OPENROWSET

1️⃣ — Préparer SQL Server et l’environnement
 Étape 1 : Vérifier la version de SQL Server
SELECT @@VERSION;


Résultat attendu : Microsoft SQL Server 2022 (64-bit)
Cela confirme que tu dois utiliser le pilote 64 bits.

 Étape 2 : Installer le pilote OLEDB pour Excel (64 bits)

Télécharge depuis le site Microsoft : AccessDatabaseEngine_X64.exe

Ensuite :

Installe la version 64 bits (si besoin en mode silencieux avec /quiet).

Redémarre ton PC.

Étape 3 : Vérifier que le pilote est bien détecté
EXEC sp_enum_oledb_providers;


Tu dois voir apparaître :

Microsoft.ACE.OLEDB.12.0
Microsoft.ACE.OLEDB.16.0


 2️⃣ — Autoriser SQL Server à utiliser le pilote
 Étape 4 : Activer les requêtes distribuées
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;

Étape 5 : Autoriser le fournisseur OLEDB à s’exécuter dans le processus en mode admin

GO
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1;
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1;
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.16.0', N'AllowInProcess', 1;
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.16.0', N'DynamicParameters', 1;
GO


 Pense à redémarrer le service SQL Server (SQLEXPRESS) via services.msc.

 3️⃣ — Préparer le fichier Excel

 4️⃣ — Importer les données avec OPENROWSET
Étape 7 : Exécuter la commande SQL
SELECT * INTO CovidVaccinations
FROM OPENROWSET('Microsoft.ACE.OLEDB.16.0',
   'Excel 12.0;Database=C:\Users\maria\Desktop\CovidVaccinations.xlsx;HDR=YES',
   'SELECT * FROM [CovidVaccinations$]');









GO
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1;
GO
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1;
GO


GO
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1;
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1;
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.16.0', N'AllowInProcess', 1;
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.16.0', N'DynamicParameters', 1;
GO


-- Autoriser les options avancées
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

-- Activer les requêtes ad hoc distribuées
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;

-- Vérifier si c’est bien activé
EXEC sp_configure 'Ad Hoc Distributed Queries';


SELECT * INTO CovidVaccinations
FROM OPENROWSET('Microsoft.ACE.OLEDB.16.0',
   'Excel 12.0;Database=C:\Users\maria\Desktop\CovidVaccinations.xlsx;HDR=YES',
   'SELECT * FROM [CovidVaccinations$]');
