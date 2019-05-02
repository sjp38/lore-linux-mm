Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 718E0C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 18:24:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1648120675
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 18:24:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=microsoft.com header.i=@microsoft.com header.b="lVD7TYgo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1648120675
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=microsoft.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A18E76B0003; Thu,  2 May 2019 14:24:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C8BF6B0006; Thu,  2 May 2019 14:24:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88FFF6B0007; Thu,  2 May 2019 14:24:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3D2BD6B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 14:24:43 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h2so397203edi.13
        for <linux-mm@kvack.org>; Thu, 02 May 2019 11:24:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:msip_labels:content-transfer-encoding:mime-version;
        bh=I8obnoPpE/nhmGGbqB5I9zlhg4YmLppQW2PFEAZf8qA=;
        b=SIXqOSPWslmVkywBAdwFNU3y3bFlayxtHzpODZYBuuVg7jJ0jdxTRJWMIo1LEWULOm
         RO/SbXfC/Vnj0523Tx+fdOFedbYCngivueTy5GI9DjrvZmWV+vVFQGT3ZhoGKEqId4Za
         +EESRNS2m8+FgX1D14qZ0d3WfE4WWGSdw7qCfBqaXq+cLPyf7oLRWTzJLmHPeY6wKicw
         B3lXd53h/AtpL+n15cefrUNGXiCcXz3VWW6TO+GPQSiQkysYDAGg58heegasakMBAa6i
         v5cX3J1Q3ozIyIX1H8+76EmFVi+K9d7IRhQxGjEPsxHJbxbB8P0XSjWkIdxVDDnfKvlm
         uqtQ==
X-Gm-Message-State: APjAAAWLlyi7oKZzIcghVcGfAOf2+gspD/LWSrk3zpGtxgHwF15jOKdH
	IsET6QQ5VZG57sr8JxmYAUxv8zys/T5BMsQg5gi2aQ4rPaikFYQ/56AsoUijU1AsILfXdGjymaB
	Qu13Cki/ngFM3HPTj5GjkHN5glhey3J0J4/iJapKujB2fXTIF+aJfuDhJcd0pYx3q1g==
X-Received: by 2002:a17:906:43c4:: with SMTP id j4mr506654ejn.262.1556821482682;
        Thu, 02 May 2019 11:24:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzrWVxjsBZzQORt5OEFbkIPW3pQjgRBQARWacZiput1ZyGWkcJ5mfc85hVWdctn1qIbIhiT
X-Received: by 2002:a17:906:43c4:: with SMTP id j4mr506622ejn.262.1556821481660;
        Thu, 02 May 2019 11:24:41 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1556821481; cv=pass;
        d=google.com; s=arc-20160816;
        b=JqCQ7oX+EoWt+EeIyHFjcSvhZp7W6Nf523ki+PizlKK8zf9BQBECc7/CsnJ08aPvHN
         7zGXrzR4ocPnrAV5CeKooCLTmmR5Ezk0xbqrgHnNO2AlWYxVbZ1eXt0bbcnVsNS8efwf
         xu+tSTsD4yC85DEROUw0r7jC1wPZP3EqyFYguOOgeBn8NrUqlo+XDcZ4279yM/b1Rim2
         dRJ7tnfMkLpL6RaOxq9dFW2VjxWUXO7LJtfQww9s/otEHrlcczsg4rg+pX233NDQ5vJk
         uK3gHYY44qZpCH+MGAOME9HBwjglnTPF7wmsPoSqMJngcom7Kc6DPzHmG2rcI9DDm0JE
         1yNw==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:msip_labels:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=I8obnoPpE/nhmGGbqB5I9zlhg4YmLppQW2PFEAZf8qA=;
        b=i/uuR0nGnJC35bR0nm07xPY/sNi0sWiMGLk4iCz0TaGPQqPk2jPfyKGECRrBc5bnZr
         AYddqpowKCFp9BDqY4/Rg1W3Aszh2mWySie6dvhMgyztZFgcSeXj8lSharDL9y6s2zv8
         b0Pgmi6JSLIgf6Hurr+fHEBHiKoNS6+o0L3Unv3WQRfgjwKWjLWudNwEWV8FGajTbwCv
         IJ0Mfiz3nIVTw5N+kRb9EzicXkNEKUtOrymUoWP5DuDLSgvs/K4lwSGjXXzDukA0V5/E
         yuAUoek4knLHfc7RM7ZiQprd02CBToJSTWNexTIOVXI5XrzZ9Dbh+WEGDKwm2QTAPgk/
         Lrpw==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@microsoft.com header.s=selector1 header.b=lVD7TYgo;
       arc=pass (i=1);
       spf=pass (google.com: domain of decui@microsoft.com designates 40.107.131.132 as permitted sender) smtp.mailfrom=decui@microsoft.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=microsoft.com
Received: from APC01-SG2-obe.outbound.protection.outlook.com (mail-eopbgr1310132.outbound.protection.outlook.com. [40.107.131.132])
        by mx.google.com with ESMTPS id q6si4823326edg.394.2019.05.02.11.24.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 May 2019 11:24:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of decui@microsoft.com designates 40.107.131.132 as permitted sender) client-ip=40.107.131.132;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@microsoft.com header.s=selector1 header.b=lVD7TYgo;
       arc=pass (i=1);
       spf=pass (google.com: domain of decui@microsoft.com designates 40.107.131.132 as permitted sender) smtp.mailfrom=decui@microsoft.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=microsoft.com
ARC-Seal: i=1; a=rsa-sha256; s=testarcselector01; d=microsoft.com; cv=none;
 b=EE96FFwkMszatMOo+Ds/aPmsV4W2TDJW/UFdsA6FZ6aGOH2nqPhx1rjdLiU1vt/1A2Q0dKnHP8PRzd6ZFdedZ3Uuo1AUTDTrjvTv/QGmxx7iMr7r42KBe7sfK0a98gvFXIh8FHFutckL2iW5S5PCLPvH7qbxCekfufBIjlcxo8c=
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=testarcselector01;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=I8obnoPpE/nhmGGbqB5I9zlhg4YmLppQW2PFEAZf8qA=;
 b=MtZU3lKOtjdnMB4hOTcUIjc51ywOiaZVKxAJzgX9Vuc/iwISEoXNJSfB46HMHd/xGtyUW9fBTrmpXGtFw/mfpxiTYOSLwWaR06JlgOaQGZfXq1AdsZOBEL5iaS6G6Ph/GcILogjZJJM73GYru1MoErlOfnUxvkfywZM08SiFWxA=
ARC-Authentication-Results: i=1; test.office365.com 1;spf=none;dmarc=none
 action=none header.from=microsoft.com;dkim=none (message not signed);arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=I8obnoPpE/nhmGGbqB5I9zlhg4YmLppQW2PFEAZf8qA=;
 b=lVD7TYgoA7d8Kngl/j14AJFtfP8UdM159qfvqICkySMDlKEu4RaY4w33tYwyQFga5Ppm5kCdB0LeH/dgc38yIK8OrznFlWthKg87rJ/wAKBz2YHR2ruLlqn/IFqMDEbASXuvMmN7UBZSrytihxFRrVrqlj5KICjPLpbSAxsUtOw=
Received: from PU1P153MB0169.APCP153.PROD.OUTLOOK.COM (10.170.189.13) by
 PU1P153MB0123.APCP153.PROD.OUTLOOK.COM (10.170.188.16) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1856.4; Thu, 2 May 2019 18:24:33 +0000
Received: from PU1P153MB0169.APCP153.PROD.OUTLOOK.COM
 ([fe80::9810:3b6b:debd:1f16]) by PU1P153MB0169.APCP153.PROD.OUTLOOK.COM
 ([fe80::9810:3b6b:debd:1f16%4]) with mapi id 15.20.1856.004; Thu, 2 May 2019
 18:24:33 +0000
From: Dexuan Cui <decui@microsoft.com>
To: Michal Hocko <mhocko@suse.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton
	<akpm@linux-foundation.org>, Kirill Tkhai <ktkhai@virtuozzo.com>, Johannes
 Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Roman
 Gushchin <guro@fb.com>, Hugh Dickins <hughd@google.com>, Andrey Ryabinin
	<aryabinin@virtuozzo.com>, Mel Gorman <mgorman@techsingularity.net>,
	"dchinner@redhat.com" <dchinner@redhat.com>, Greg Thelen
	<gthelen@google.com>, Kuo-Hsin Yang <vovoy@chromium.org>
Subject: RE: isolate_lru_pages(): kernel BUG at mm/vmscan.c:1689!
Thread-Topic: isolate_lru_pages(): kernel BUG at mm/vmscan.c:1689!
Thread-Index: AdUAdyzy8F3SUITdRv6SToKOnShIegAbxvIAAAs/qiA=
Date: Thu, 2 May 2019 18:24:33 +0000
Message-ID:
 <PU1P153MB0169009CB69F8365EBE6FC6EBF340@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
References:
 <PU1P153MB01693FF5EF3419ACA9A8E1FDBF3B0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
 <20190502125514.GB29835@dhcp22.suse.cz>
In-Reply-To: <20190502125514.GB29835@dhcp22.suse.cz>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
msip_labels: MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_Enabled=True;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_SiteId=72f988bf-86f1-41af-91ab-2d7cd011db47;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_Owner=decui@microsoft.com;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_SetDate=2019-05-02T18:24:30.0210155Z;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_Name=General;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_Application=Microsoft Azure
 Information Protection;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_ActionId=f9be8985-b867-4956-a842-152705123cef;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_Extended_MSFT_Method=Automatic
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=decui@microsoft.com; 
x-originating-ip: [2001:4898:80e8:1:95ff:69b:baac:db8f]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 1b61ad2d-494a-4f61-ee97-08d6cf2b6d01
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4618075)(2017052603328)(7193020);SRVR:PU1P153MB0123;
x-ms-traffictypediagnostic: PU1P153MB0123:
x-ld-processed: 72f988bf-86f1-41af-91ab-2d7cd011db47,ExtAddr
x-microsoft-antispam-prvs:
 <PU1P153MB0123B5675AA8FED25B45CAE0BF340@PU1P153MB0123.APCP153.PROD.OUTLOOK.COM>
x-ms-oob-tlc-oobclassifiers: OLM:8273;
x-forefront-prvs: 0025434D2D
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(136003)(39860400002)(396003)(346002)(366004)(376002)(189003)(199004)(446003)(305945005)(25786009)(6246003)(7696005)(229853002)(71200400001)(71190400001)(256004)(76176011)(55016002)(2906002)(86612001)(11346002)(46003)(9686003)(86362001)(5660300002)(99286004)(316002)(74316002)(54906003)(7736002)(478600001)(476003)(22452003)(4744005)(6916009)(486006)(186003)(6436002)(4326008)(10090500001)(8936002)(8990500004)(68736007)(14454004)(7416002)(73956011)(81156014)(33656002)(76116006)(53936002)(6116002)(66946007)(66556008)(66476007)(66446008)(102836004)(64756008)(10290500003)(8676002)(52536014)(6506007)(81166006);DIR:OUT;SFP:1102;SCL:1;SRVR:PU1P153MB0123;H:PU1P153MB0169.APCP153.PROD.OUTLOOK.COM;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:3;
received-spf: None (protection.outlook.com: microsoft.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 A1OCSBsR6tlUbaktEednYVvvuRZKv5EU/WJoDMuY7ffrqRwA4Rm6TfpuPe/5RGLp09p+nKalPhrLX9qIOVKuKC5SBHZuHAIHnIFUi4tnnrO7HyJLcctIfso5yx3yej/oJ/TLbjZ9OYps5iLvFoyksYStnjW3qxO5GoKvyoYxbvnbZTowyZTiN2zKliu1lkgN3N4Gut2lIJdumFtzXjSgzF013GkKi3EKIg+pRFUB6RwhA8ed4J0R1tOeF1BKGahdSIZilhT/z7YnvxCU5rJNREquQn+EGPp83RKDaNqU3A/4BaYDG59EBOa/d4KCeO2GoOyvc0x4IPK0c+sPjsZMH+xJbGLQ2zuK9mHQnoghaQOEQ7aN4Bft8l7aEvRmSszQqapzzITncUMiBUu9ZsTbwplQl53mwSzlecXne3Owy6o=
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: microsoft.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 1b61ad2d-494a-4f61-ee97-08d6cf2b6d01
X-MS-Exchange-CrossTenant-originalarrivaltime: 02 May 2019 18:24:33.5032
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 72f988bf-86f1-41af-91ab-2d7cd011db47
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: PU1P153MB0123
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> From: Michal Hocko <mhocko@suse.com>
> Sent: Thursday, May 2, 2019 5:55 AM
> > ...
> > So far I only hit the BUG once and I don't know how to reproduce it aga=
in, so
> this is just a FYI.
>=20
> ...
> Do you think it would be possible to setup a crash dump
> or apply the following debugging patch in case it reproduces?
> Michal Hocko

Now I applied the "dump_page(page);" and let's see if I'll hit the BUG agai=
n.

BTW, I'm developing some code to support hibernation for Linux VM running
on Hyper-V. I don't think my own change causes the BUG, as my change does n=
ot
touch the mm system or any file system code at all.

Thanks,
-- Dexuan

