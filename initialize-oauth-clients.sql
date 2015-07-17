/*
Here is the format of the insert:

INSERT INTO oauth_client_details 
            (client_id, 
             resource_ids, 
             client_secret, 
             scope, 
             authorized_grant_types, 
             web_server_redirect_uri, 
             authorities, 
             access_token_validity, 
             refresh_token_validity, 
             additional_information, 
             autoapprove) 
VALUES      ('CLIENT-ID', 
             'dataPoint', 
             'CLIENT-SECRET', 
             'read_data_points,write_data_points', 
             'implicit', 
             'http://localhost:3000/mobility_dashboard', 
             'ROLE_CLIENT', 
             NULL, 
             -1, 
             NULL, 
             'read_data_points,write_data_points'); 
*/

INSERT INTO oauth_client_details 
            (client_id, 
             resource_ids, 
             client_secret, 
             scope, 
             authorized_grant_types, 
             web_server_redirect_uri, 
             authorities, 
             access_token_validity, 
             refresh_token_validity, 
             additional_information, 
             autoapprove) 
VALUES      ('io.smalldatalab.android.pam','dataPoint',{GET THIS FROM SMALL DATA LAB},'write_data_points','authorization_code,refresh_token','oauth://callback','ROLE_CLIENT',null,-1,null,'write_data_points'); 

INSERT INTO oauth_client_details 
            (client_id, 
             resource_ids, 
             client_secret, 
             scope, 
             authorized_grant_types, 
             web_server_redirect_uri, 
             authorities, 
             access_token_validity, 
             refresh_token_validity, 
             additional_information, 
             autoapprove) 
VALUES      ('io.smalldatalab.android.ohmage','dataPoint',{GET THIS FROM SMALL DATA LAB},'write_data_points','authorization_code,refresh_token','oauth://callback','ROLE_CLIENT',null,-1,null,'write_data_points'); 

INSERT INTO oauth_client_details 
            (client_id, 
             resource_ids, 
             client_secret, 
             scope, 
             authorized_grant_types, 
             web_server_redirect_uri, 
             authorities, 
             access_token_validity, 
             refresh_token_validity, 
             additional_information, 
             autoapprove) 
VALUES      ('io.smalldatalab.android.mobility','dataPoint',{GET THIS FROM SMALL DATA LAB},'write_data_points','authorization_code,refresh_token','oauth://callback','ROLE_CLIENT',null,-1,null,'write_data_points');

INSERT INTO oauth_client_details 
            (client_id, 
             resource_ids, 
             client_secret, 
             scope, 
             authorized_grant_types, 
             web_server_redirect_uri, 
             authorities, 
             access_token_validity, 
             refresh_token_validity, 
             additional_information, 
             autoapprove) 
VALUES      ('mobility-visualization','dataPoint',{GET THIS FROM SMALL DATA LAB},'read_data_points','implicit','http://judywu.github.io/mobility-ui/','ROLE_CLIENT',null,-1,null,'read_data_points');


