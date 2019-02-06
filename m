Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F3B1C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 12:23:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1AB72175B
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 12:23:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=nxp.com header.i=@nxp.com header.b="OAYpjFnO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1AB72175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nxp.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C41C8E00B6; Wed,  6 Feb 2019 07:23:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 699578E00AA; Wed,  6 Feb 2019 07:23:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 589B18E00B6; Wed,  6 Feb 2019 07:23:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 010A98E00AA
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 07:23:47 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id v4so2682731edm.18
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 04:23:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:thread-topic
         :thread-index:date:message-id:accept-language:content-language
         :content-transfer-encoding:mime-version;
        bh=faxl/KezfUlP0iYen5kcYslR6D1Jt/hhhdjyT20wRzU=;
        b=Qqd18itMlLlCxD1lw6cszvb6gA3ZdPcK5Ko8f4a15/3XXJ9zkMq2xTpq2SBzRWTtEw
         bws43zbIFIoeh9hj+tRaOWINIAanx0nPNgOEwZixvLGjMQcF9/jCCqBsOs2tEBPK7y49
         yhr4w7zVmKCokhEFKdv2xCZdhrpzkjh9hMH6IUS8XWdvphPDxqCwGUioLeGCP0ULppgL
         JoIcgIOG7Kd3QG7JM+wArwcfRKu547vcZu3UHZwP9S/fVLjHMFii5/Qny/VZu0OGOGMI
         SypnLAglexcEdewPpjdN7H+WLqSAMcp7wGLiBjyXMMtXARwzE6gEA2H6cYRpwPGg7Jw3
         v8MA==
X-Gm-Message-State: AHQUAuZ/Q7xAEn9/ANFR0HFCH+8tVM1iIdCovCBJf1GiXNOurAT3IHJZ
	3y47CtAQqFELcdGeh3eGDFkWltuu0LF7gISa/dK9Zz+SrgN7pm3mv4yW+gPKRDn05NGyDF9lQIn
	eJAb/tjkvCK09jlEr7alnmszT/AQvVMb+j3IQhDDTQWn3zKn28BYjLzutbYg0IpqIVg==
X-Received: by 2002:a17:906:1d16:: with SMTP id n22mr7377053ejh.195.1549455827342;
        Wed, 06 Feb 2019 04:23:47 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY314+BWMwaseiBscHKP3wmV13SLNrOvRl3Wscu46r1b4+P0KWd53hJEftCw8szXg2Kc/Ew
X-Received: by 2002:a17:906:1d16:: with SMTP id n22mr7376973ejh.195.1549455825980;
        Wed, 06 Feb 2019 04:23:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549455825; cv=none;
        d=google.com; s=arc-20160816;
        b=IOkNXhV1PqcXUzvKwLHTY6f0bCywqfY1WBxrcgUoEcV6bnmtV4GpYlNJ8Xd+VqBHXA
         M2Ns9ajxbLKpF6kfeW34bzCcrvhhOV2w14Sj1jcbwoqLa5eZsyxW6YJhJhjAPSYIrkw0
         U4TGSi3ilkPmz1eEiAaJfAjLmri//J/F7ZMJQOKIG1ur26jI9Ukf9EHm5edV2C5lerMo
         FplprsjPmr6mRrj0eoCIlw+ax3LCykQ1xUgzzX7j3d8XQxCJVVLlxGbef8ODt/QApdj2
         iG7RjIek2aWDx/6nHTlRS80BVpw3PJgZkgibaybEPB5VPpZwXKcHiFGLPihNhnW/1nZC
         jQMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :to:from:dkim-signature;
        bh=faxl/KezfUlP0iYen5kcYslR6D1Jt/hhhdjyT20wRzU=;
        b=YtG0ce6zprttrh4LMcgKYB5EEb2uEUfRnG4M33h6/S9n1cXQteAR1kVBbI110FwLlY
         7ys3rIhs+bxjVOX+TCbZ0LEXX4A80zEomrbrH1Chx5bETS5ycDwrCE4OXymAsLsUDJwR
         vw+/xzLKEWOl6UFu5ixEbp7uyuU29vurg/1YwhZGskk9z3d9oLJtXxJPMybXYunxM0sQ
         5c04Cb3hfrc4jqZi0YsnzMziKhO8gmx+pM5y7LWD9G7rKqcTqlBRo/eEgzg+W1+07Sbh
         g+88JfdLvhi1XK17KO7FVahhZ5j3wCuKI36RcdMkqtusqXlWlOtGf+uAgx4w9ywbSl4v
         AHow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=OAYpjFnO;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.2.79 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20079.outbound.protection.outlook.com. [40.107.2.79])
        by mx.google.com with ESMTPS id ck12si671048ejb.122.2019.02.06.04.23.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 06 Feb 2019 04:23:45 -0800 (PST)
Received-SPF: pass (google.com: domain of peng.fan@nxp.com designates 40.107.2.79 as permitted sender) client-ip=40.107.2.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=OAYpjFnO;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.2.79 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nxp.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=faxl/KezfUlP0iYen5kcYslR6D1Jt/hhhdjyT20wRzU=;
 b=OAYpjFnOOgbRhjTn0726RyRjdSiJTQxW9xxc40v62+csTQR7QMYX41CtGWun0qmfjhGjkYg7GS984uX9FXM5hqW+OPMORFs+PP1eOV6eQiPd3anTMBG+Z0ETJ8XmpXjp6rawAmKxXjKDWda7xCIg5k/m+KNBdv180lWBzu7Dy34=
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com (52.135.148.143) by
 AM0PR04MB5939.eurprd04.prod.outlook.com (20.178.112.13) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1580.22; Wed, 6 Feb 2019 12:23:44 +0000
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::69ce:7da3:3bcf:d903]) by AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::69ce:7da3:3bcf:d903%3]) with mapi id 15.20.1580.019; Wed, 6 Feb 2019
 12:23:44 +0000
From: Peng Fan <peng.fan@nxp.com>
To: "dennis@kernel.org" <dennis@kernel.org>, "tj@kernel.org" <tj@kernel.org>,
	"cl@linux.com" <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: pcpu_create_chunk in percpu-km
Thread-Topic: pcpu_create_chunk in percpu-km
Thread-Index: AdS+Flase9I8QatNRpiWvSscyNdChg==
Date: Wed, 6 Feb 2019 12:23:44 +0000
Message-ID:
 <AM0PR04MB44813C69CCAE720A47164EA8886F0@AM0PR04MB4481.eurprd04.prod.outlook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=peng.fan@nxp.com; 
x-originating-ip: [119.31.174.68]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;AM0PR04MB5939;6:XmGDrhWk3oMh4PzsiqxLDihWuIopmrY6fHVPfvtMkrxXKep6e0RqaXfgAn/uZ3iSeI89ZvYx7yLck7mJucOTfwmli3w2Z4JRW7fcUwP/8zqXGpXruxqR4cJnpNKDOAjKEFJvLYUj37McZnpyJZV/oqXdzrWdWq8ADBh/SaLG2v/bGm+iGOoaVj6Yn9jQQ+8Zyi7DeE2IiECp9o40/3GiZ7Uva3W5ZNHUz7FASDANjty5RIt53VqCKFMMFznDpKKjzHxylYHcHaagWIVPKZjosmok5JnQ6iEffSVfjdwcPEOdNKjtS+kBbu8lAzsB8Tu0DnpVc8i50TeLsRNg/yE9Zi2iRNVVZWuUQQw/bvIjWDUo5vo51kZil4ZLPLenBOl4kRACpBGpWkkrF6yFATGfpR/8YZ/P//mf1S6IenTbS30NjooatFukkHxzGsbwo+MjLipZPS6ZmA1r68FPbx6bpQ==;5:N7nZmb9WveBrZ8zCOFldb/X3SBrzs18MssZN2hgSS7N+maFV2nmKl6eJmPzDpET02qoK/2CJxdeo24mHJkNBWXzxmPhwJ8YxkpTakbV2mgYBDsnTz6X23Fugb/Fi9KnFPQRPTbMp8akDHH0BKmRvSCyfhZ/Z6gtm+Ql1hC6U22uYBC0tybpCKY1QBivNrU9IB+ABzNKzuliWn+YciYfcIg==;7:HEdV17zleMZxxEWoOqTLY0zumBMswX6tKOGjuOEFM8J9/tOK0vhhcl23BDLrzH1rL5i61Eqvkx8dkkPpmfGctKl4d5Tgcxz9mB7Mo2d1jdhyg8mWecdO7ziK0dKTJky8EStVjMeforCNnCVJYsDzow==
x-ms-office365-filtering-correlation-id: ec42cc83-6c56-478a-764d-08d68c2df01c
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(4618075)(2017052603328)(7153060)(7193020);SRVR:AM0PR04MB5939;
x-ms-traffictypediagnostic: AM0PR04MB5939:
x-microsoft-antispam-prvs:
 <AM0PR04MB59397A9AA15E55E071B4F882886F0@AM0PR04MB5939.eurprd04.prod.outlook.com>
x-forefront-prvs: 0940A19703
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(346002)(136003)(366004)(376002)(39860400002)(199004)(189003)(71200400001)(71190400001)(44832011)(66066001)(486006)(4744005)(476003)(99286004)(478600001)(97736004)(81166006)(8676002)(74316002)(81156014)(106356001)(305945005)(2906002)(316002)(33656002)(2201001)(25786009)(110136005)(86362001)(6116002)(3846002)(9686003)(256004)(26005)(55016002)(6506007)(8936002)(68736007)(7736002)(186003)(2501003)(53936002)(14454004)(7696005)(102836004)(105586002)(6436002);DIR:OUT;SFP:1101;SCL:1;SRVR:AM0PR04MB5939;H:AM0PR04MB4481.eurprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: nxp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 xsGuIUw3RaWHKKPAmAemLTHeUuwe//EEr/dvzXPkP0G1G8HhVAYf+nneJSvM5n/WbzVskjAWZvTCcVerN1pchy4ZL2joTOW5q5RvooqxtOG4Ty54I3h3yOzJCL3UwsFC8GGaTQAgHO0/vV1mVeSFdBpA/FFfZMDy4+reGbX7VjjEaNs6oD5WQUB934pLUBC8c/jTa7miQPeCgJRQ698yDjk3pVH/8xKDXzNbtcCDBJBxc+EMvgfi0Te2uIRTPEl0I0PGTz9sUTdgo/OGl+LOkJLvTDYwrvPZ5J2RAgq9Lt/h6Wom6T2XYa8CNVf7df7G0oxRI8esfPdB4Xst9SdDgGtrUM8ZG8ZXsJFyMg/MJK+f90syB4u73OQMvuo+zbkLJW6ks2H/a9oxhjlXna6VQARsnMa1AR82vnpbUaS/2CQ=
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: nxp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: ec42cc83-6c56-478a-764d-08d68c2df01c
X-MS-Exchange-CrossTenant-originalarrivaltime: 06 Feb 2019 12:23:44.8277
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 686ea1d3-bc2b-4c6f-a92c-d99c5c301635
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AM0PR04MB5939
X-Bogosity: Ham, tests=bogofilter, spamicity=0.005812, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I am reading the percpu-km source code and found that in
pcpu_create_chunk, only pcpu_group_sizes[0] is taken into
consideration, I am wondering why other pcpu_group_sizes[x]
are not used?

Is the following piece code the correct logic?

@@ -47,12 +47,15 @@ static void pcpu_depopulate_chunk(struct pcpu_chunk *ch=
unk,

 static struct pcpu_chunk *pcpu_create_chunk(gfp_t gfp)
 {
-       const int nr_pages =3D pcpu_group_sizes[0] >> PAGE_SHIFT;
+       int nr_pages =3D 0;
        struct pcpu_chunk *chunk;
        struct page *pages;
        unsigned long flags;
        int i;

+       for (i =3D 0; i < pcpu_nr_groups; i++)
+               nr_pages +=3D pcpu_group_sizes[i] >> PAGE_SHIFT;
+
        chunk =3D pcpu_alloc_chunk(gfp);
        if (!chunk)
                return NULL;

Thanks,
Peng.

