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

Étape 5 : Autoriser le fournisseur OLEDB à s’exécuter dans le processus
USE master;
GO
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1;
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1;
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.16.0', N'AllowInProcess', 1;
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.16.0', N'DynamicParameters', 1;
GO


 Pense à redémarrer le service SQL Server (SQLEXPRESS) via services.msc.

 3️⃣ — Préparer le fichier Excel
Étape 6 : Vérifier le fichier
Élément	Détail
Nom du fichier	CovidVaccinations.xlsx
Emplacement	C:\Users\maria\Desktop\CovidVaccinations.xlsx
Feuille	CovidVaccinations (et non Sheet1)
Première ligne	Contient les noms de colonnes (iso_code, continent, etc.)
⚠️ Important	Le fichier doit être fermé avant l’import.
 4️⃣ — Importer les données avec OPENROWSET
Étape 7 : Exécuter la commande SQL
SELECT * INTO CovidVaccinations
FROM OPENROWSET('Microsoft.ACE.OLEDB.16.0',
   'Excel 12.0;Database=C:\Users\maria\Desktop\CovidVaccinations.xlsx;HDR=YES',
   'SELECT * FROM [CovidVaccinations$]');

Détails :
Élément	Explication
Microsoft.ACE.OLEDB.16.0	Pilote Excel
Excel 12.0	Format .xlsx
HDR=YES	Première ligne = noms de colonnes
[CovidVaccinations$]	Nom exact de la feuille Excel (avec $)
5️⃣ — Vérifier que l’import a réussi
SELECT TOP 10 * FROM CovidVaccinations;
