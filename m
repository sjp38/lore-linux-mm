Return-Path: <SRS0=Ffi5=RF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A67BC43381
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 13:48:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4AE6B20838
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 13:48:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=nxp.com header.i=@nxp.com header.b="jhSG3MGH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4AE6B20838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nxp.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BEEB68E0003; Sat,  2 Mar 2019 08:48:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B9F068E0001; Sat,  2 Mar 2019 08:48:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A67D88E0003; Sat,  2 Mar 2019 08:48:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4B75F8E0001
	for <linux-mm@kvack.org>; Sat,  2 Mar 2019 08:48:24 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id h16so412169edq.16
        for <linux-mm@kvack.org>; Sat, 02 Mar 2019 05:48:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=zykTx7N7nntqgGmmjdaPjlTkahbZ/HG4ZXMHdHiwkcQ=;
        b=TLiQ5Npamw0t9eFERSVLVyUuTTqfwg3kE9cSKUQkAxK0zRXmwqnuKh6WNQgOaVesEK
         UtIF04mBqHe8Hfw5YQLMTgjOex04hK1B/QuKt3g0M0YYSEWwH6NVAxeZzLQnBMS8VJfo
         MkKEx645zqb9ADI3QtqIhXVL7rBNBMBPaA7+kXAYa1rfWOfBdQ5ujGpsnK9sxFo76fVs
         BDUahJV8K4GlhygLRlU+DTkQ80EY5og5FNOYgu3DlS3qnK0KJqiAAguCWv/ROl8+LBoI
         NS5M74MW+TY2HP6MRxKJT0YVFRtiXwpWWtQnFZ0iJdK31OeCS05P9YzFwpeAFj25igd1
         wYJA==
X-Gm-Message-State: APjAAAWZuP5+x8G4OOnktl/C/Sv+ljAPrTgD2qXHml5GxY55AnA9eo02
	VMeoPfyzg4QAEUUbaKfMyP2rqIz5V2Idvh3aoXXS/BUKZUy5l2FPQ5UwBwSB4R3owrBn7ZXYg5Q
	+cCTs0633TOl7v9ubjjXnGDS3EhjlbqIE9Y2N3Ng+zvYJHQW5/SbXdQ9Ov0LlDOtoPA==
X-Received: by 2002:a17:906:4044:: with SMTP id y4mr6573503ejj.93.1551534503735;
        Sat, 02 Mar 2019 05:48:23 -0800 (PST)
X-Google-Smtp-Source: APXvYqxMxFxjlMBhsSinmEgdkLOpj7H5GTbR224ki6zbrCFMJ2O6jLkNgR+lHqDAD2+SERq9MwlY
X-Received: by 2002:a17:906:4044:: with SMTP id y4mr6573464ejj.93.1551534502892;
        Sat, 02 Mar 2019 05:48:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551534502; cv=none;
        d=google.com; s=arc-20160816;
        b=h8MICrVB7u2G61y1ZZqETVMj9+59c+G00Km+U30S2G0tCfhg6KMB7Hf1RNuDpEHA//
         D2rTL9Gar3+ocdoYXn767adycZPsb2fZutJ+GYC5pgHAlpQYmvvNZAbrlrMzg6mdxb5r
         /id6qvyUDPLhno5f954Q/LbUaxLp4Br9YuM2AtvyqpJ8m287P+jwEM2CtC+L2bFGWSR3
         TFW6GSNN0Q6adRjwPcfQdkPRhm6sGAuY5hH6J1dXACW6lr6MizTEo7x0N8YlGU7e9Njy
         Cti3zo/SRfg1giBvaUnDs/PnJY5LWx704WLh1oXtb7RDg2AVvLssO5iYMVU2U5FXxE+Y
         oiyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=zykTx7N7nntqgGmmjdaPjlTkahbZ/HG4ZXMHdHiwkcQ=;
        b=UAks7F1+wYESKNboEd9YVV4DJNIFvM8ZlKS1lgucBoDvUMj6Kq9dchkK189oRVl5Xh
         QN6klMABvwyLvFG9gTOJ2sBuwydhAny5h6RNzMw6+rwQqxPcF1K/iwpqVVNN9EAbFw5S
         v1EwJc9eV4eL4sNn+EOwpmiQqgdGJzjMLeJyVhXPG5iWi43A6tsc/ovPq8/zyBm+RigK
         oITYtPNJS4bJZxKELxSp7V3HuvKvnpuV53wT2Gw/zmbvCAEUvguHT3i/IBNTdSltNRrD
         fbJeEdnxC5/za0xITwELW2MKa0+tqa/fWauFjV87r5nCTuHhJrPeoAY0DXGAi5BJ286T
         pAiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=jhSG3MGH;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.1.68 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10068.outbound.protection.outlook.com. [40.107.1.68])
        by mx.google.com with ESMTPS id c4si92365edb.409.2019.03.02.05.48.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Mar 2019 05:48:22 -0800 (PST)
Received-SPF: pass (google.com: domain of peng.fan@nxp.com designates 40.107.1.68 as permitted sender) client-ip=40.107.1.68;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=jhSG3MGH;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.1.68 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nxp.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=zykTx7N7nntqgGmmjdaPjlTkahbZ/HG4ZXMHdHiwkcQ=;
 b=jhSG3MGHfmgYnFz4W0cLXx0ybpVHdGMvjuTSyFtMEloVb8J3uPY2UFxDgZgJSmznO1riD5CdEIOB2tekfY06VEjqSRYR7Wha6H3XhnSyRkt2DviQuFW9S/YBSfz/MrVtdh4lozFJ95pYKfw8trw1Eaw8E4R9CUkVkDgR3M4GV9Q=
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com (52.135.147.15) by
 AM0PR04MB4257.eurprd04.prod.outlook.com (52.134.124.147) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.16; Sat, 2 Mar 2019 13:48:21 +0000
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185]) by AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185%5]) with mapi id 15.20.1665.019; Sat, 2 Mar 2019
 13:48:21 +0000
From: Peng Fan <peng.fan@nxp.com>
To: Dennis Zhou <dennis@kernel.org>, Tejun Heo <tj@kernel.org>, Christoph
 Lameter <cl@linux.com>
CC: Vlad Buslov <vladbu@mellanox.com>, "kernel-team@fb.com"
	<kernel-team@fb.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: RE: [PATCH 04/12] percpu: manage chunks based on contig_bits instead
 of free_bytes
Thread-Topic: [PATCH 04/12] percpu: manage chunks based on contig_bits instead
 of free_bytes
Thread-Index: AQHUzwv2qzl7fj3BX0OARXhmoz6omaX4XeFQ
Date: Sat, 2 Mar 2019 13:48:20 +0000
Message-ID:
 <AM0PR04MB4481BE90E46F3635B7131CED88770@AM0PR04MB4481.eurprd04.prod.outlook.com>
References: <20190228021839.55779-1-dennis@kernel.org>
 <20190228021839.55779-5-dennis@kernel.org>
In-Reply-To: <20190228021839.55779-5-dennis@kernel.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=peng.fan@nxp.com; 
x-originating-ip: [119.31.174.68]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 1c8bbfd1-f117-442f-2f4b-08d69f15bbaa
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:AM0PR04MB4257;
x-ms-traffictypediagnostic: AM0PR04MB4257:
x-microsoft-exchange-diagnostics:
 =?gb2312?B?MTtBTTBQUjA0TUI0MjU3OzIzOmI5ZTNSaWE1bms2ZVFRYnh2ZjJrM2RCUWhI?=
 =?gb2312?B?MlluRTB2ZjZEUFFWSkc5bG8xSmY1dDFmNGNrZFk4OS9rMnRaM1l2eTduNlNV?=
 =?gb2312?B?THJ4aHUvVGxPbWxDeDd0WHRaZzJZeGJsL0dkd0p5TjZUeFFuN1Z5UFNhYzdZ?=
 =?gb2312?B?VE1BN2V0dlRBNFBraWhydmJrKytKa1h6SVhNbG1SdUJab1RhZDkxVjRyN2NS?=
 =?gb2312?B?WUl0blgrejllMXZlMko3NmtwbXc5SlNZMkt1a2I0TUxvNHdOZzZ1OTBwZlFO?=
 =?gb2312?B?enNkSlh4RmR1WVFudUxpWHZMbjNHTFUySkxqU0U5dTNMV3htT01tNWUwTTh2?=
 =?gb2312?B?NmRNU2FlRC82QlJCbVVEM0ZwTkJ2ODdoem9ucldBMUxqakRuYklNZmNpUGlE?=
 =?gb2312?B?ektxNXQ5c000dXM2dTFpeko5WTV5RGNnT2RkNUJhUDVHMWYrdEZZMFhlQWg2?=
 =?gb2312?B?UmxWb1NpckUvZitWRXhIaDdCTmdsUWd5dEhiSnA4Y1NVVytRQmJBamY4eHM5?=
 =?gb2312?B?dFI4YStrZHh0WEplSG5oVXl2cENPR0xCQldsWTl3b2lYeThLdGRuVUdtbWZE?=
 =?gb2312?B?a1pCSXFkNHFVOEI1YnVrM255Wjd2Tnc1MWhJcFo4dUFSM21kOXgrWTd6U0tU?=
 =?gb2312?B?VjhWeTI2RWkvN3NRNkZmcDV5RFBUOVpXblVwVEJmL1NvaDM5cXhCU1hUOEM4?=
 =?gb2312?B?R2hZYlZWd0hiY1RZdVlBbVpaa0duVm9SZW11TmQ4MjMxQ1lyZEx4TlhFUEVl?=
 =?gb2312?B?S25LMjNlVExuS1RVRmlzanVSVTFrZkNMQnd5RitETDF5WXM2TzRZaTlrWEwv?=
 =?gb2312?B?UnFMTTQ4QmRiTzhZUnFuZXczaUI3aXRweHE0SzQ1WXpwcUJYVTRTcThKMmt1?=
 =?gb2312?B?OUdzdFFRZXFVa1k5NHBlbUY1N2lncWk5R1d5K0NlemlJWURBY0x1SCt4RStt?=
 =?gb2312?B?bTJwNU00bzI5bnRYblptTE5Oc2FVYXo5MDVCMnVYS3JsbGI1R3psd21pU3k0?=
 =?gb2312?B?UENsalZIbEJPUzZXU2pTQ1VVQ1ByVmF5MDNvRGcvd003R3hLUHFRbXNDQXJD?=
 =?gb2312?B?Mit3OWVKeHpkczVnclloTjM0cnBmSW84MERrZFlmVWZtaDZqTUhsTU5FbGp4?=
 =?gb2312?B?Uy92c1ptZWhqTWNzSzZVYmFEVm11ZVJyYmJKSUlFYUZETFRQcGlXSmEzN1F1?=
 =?gb2312?B?ZHZvS1cxQ0ZOeE5LMEFGUUxweDkySnk1WjdPcURXbUVVR21FRHZMOWFmcEx0?=
 =?gb2312?B?ZGFHbEg4eTliT2ZFSkU5YWYrd281MW9KQTJieDBHZWFsc0NOc1c4MGpEWVBi?=
 =?gb2312?B?cTVpR2NLbUFwdFN2d2hYUm1YQjRZbGltTXAvQUhhWktUUnJlZGFDWUFjM3ZL?=
 =?gb2312?B?VjA0WndNUlBKd1FPaU9FaVVtcEtvV1g4dXBPTXQxY1ltMVVaM1dNWDF5bmtn?=
 =?gb2312?B?bmM1ZTB3ZXBFMFVmZjMxUDFaV1lyanNUeDBlOGxPNDFMbkdmWHpRNHMwdkVN?=
 =?gb2312?B?SHNGMVRCWU1SQnc4ekNJeEhhRGxyY0l2anIvRUV4em9oOUpYTWc4Z2JTa2Zq?=
 =?gb2312?B?WGZuejJtdDhJVGlqejdBcHJKYnZxazdZMm1pcTBFbGNld2t3dW9FejdYS28x?=
 =?gb2312?B?dmxSV25BRzhPVzJhRW9XaXA2VmQrR2tYekJwU1JLNkE0ZlVSK09DaHMzU2hw?=
 =?gb2312?B?WllsYm1iYmM0UEptUml1R0J4YlpYYnRPZmlrVXV4dWFqeHBlaFhLZGNYZk5M?=
 =?gb2312?B?ODg0aG42VHg4aGw4cTE3Zz09?=
x-microsoft-antispam-prvs:
 <AM0PR04MB4257CC9636A93D98565C81C688770@AM0PR04MB4257.eurprd04.prod.outlook.com>
x-forefront-prvs: 09645BAC66
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(376002)(366004)(396003)(136003)(346002)(39860400002)(13464003)(199004)(189003)(316002)(99286004)(26005)(76176011)(54906003)(478600001)(110136005)(14454004)(102836004)(7696005)(53546011)(186003)(97736004)(4326008)(25786009)(33656002)(6506007)(6246003)(68736007)(3846002)(6116002)(9686003)(8936002)(74316002)(305945005)(105586002)(7736002)(55016002)(53936002)(2906002)(66066001)(106356001)(86362001)(81166006)(81156014)(8676002)(446003)(44832011)(486006)(229853002)(5660300002)(71200400001)(71190400001)(11346002)(476003)(256004)(6436002)(52536013)(14444005);DIR:OUT;SFP:1101;SCL:1;SRVR:AM0PR04MB4257;H:AM0PR04MB4481.eurprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: nxp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 Kd2Dc+21m/M++bC5w2SZy8yuF6Mma2TLf43SHryyRMyMUD4Xun8q9U/hWGNVNqAiCsyWSxkfmckv19FOhVdsGY9w7pwiBzqFjNvpvjjlvHCnNcxwWH04WhbSWvupodz1qrzl6ggxn4cDzafQ2O85ktfPfJLF88a0rA1q/SRauFBHljq+QqwXEmEKJIEbrRo3VnG+MXfG0kSAIdMF9Z35NfVpbL/gMYAgrwGBDN4zjiebQwFvDHB4jDkDQAIPbRX1/BOaJa9okKkO5/fbX8ByflH5kU0ql2nt17kzwmzjp1pxpfvjLxJZ/V07x0264Xk1p4NVoHJFypTl0+AWuj5Cjcj/ybaXrRu49wVws3h7iNais250RYJKJTd2ZGcpsfUa30tMGv8uxavtr3HiRdHJaAOThcoZWE8BQqgFBEC62H0=
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: nxp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 1c8bbfd1-f117-442f-2f4b-08d69f15bbaa
X-MS-Exchange-CrossTenant-originalarrivaltime: 02 Mar 2019 13:48:20.9885
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 686ea1d3-bc2b-4c6f-a92c-d99c5c301635
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AM0PR04MB4257
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogb3duZXItbGludXgtbW1A
a3ZhY2sub3JnIFttYWlsdG86b3duZXItbGludXgtbW1Aa3ZhY2sub3JnXSBPbg0KPiBCZWhhbGYg
T2YgRGVubmlzIFpob3UNCj4gU2VudDogMjAxOcTqMtTCMjjI1SAxMDoxOQ0KPiBUbzogRGVubmlz
IFpob3UgPGRlbm5pc0BrZXJuZWwub3JnPjsgVGVqdW4gSGVvIDx0akBrZXJuZWwub3JnPjsgQ2hy
aXN0b3BoDQo+IExhbWV0ZXIgPGNsQGxpbnV4LmNvbT4NCj4gQ2M6IFZsYWQgQnVzbG92IDx2bGFk
YnVAbWVsbGFub3guY29tPjsga2VybmVsLXRlYW1AZmIuY29tOw0KPiBsaW51eC1tbUBrdmFjay5v
cmc7IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmcNCj4gU3ViamVjdDogW1BBVENIIDA0LzEy
XSBwZXJjcHU6IG1hbmFnZSBjaHVua3MgYmFzZWQgb24gY29udGlnX2JpdHMgaW5zdGVhZA0KPiBv
ZiBmcmVlX2J5dGVzDQo+IA0KPiBXaGVuIGEgY2h1bmsgYmVjb21lcyBmcmFnbWVudGVkLCBpdCBj
YW4gZW5kIHVwIGhhdmluZyBhIGxhcmdlIG51bWJlciBvZg0KPiBzbWFsbCBhbGxvY2F0aW9uIGFy
ZWFzIGZyZWUuIFRoZSBmcmVlX2J5dGVzIHNvcnRpbmcgb2YgY2h1bmtzIGxlYWRzIHRvDQo+IHVu
bmVjZXNzYXJ5IGNoZWNraW5nIG9mIGNodW5rcyB0aGF0IGNhbm5vdCBzYXRpc2Z5IHRoZSBhbGxv
Y2F0aW9uLg0KPiBTd2l0Y2ggdG8gY29udGlnX2JpdHMgc29ydGluZyB0byBwcmV2ZW50IHNjYW5u
aW5nIGNodW5rcyB0aGF0IG1heSBub3QgYmUgYWJsZQ0KPiB0byBzZXJ2aWNlIHRoZSBhbGxvY2F0
aW9uIHJlcXVlc3QuDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBEZW5uaXMgWmhvdSA8ZGVubmlzQGtl
cm5lbC5vcmc+DQo+IC0tLQ0KPiAgbW0vcGVyY3B1LmMgfCAyICstDQo+ICAxIGZpbGUgY2hhbmdl
ZCwgMSBpbnNlcnRpb24oKyksIDEgZGVsZXRpb24oLSkNCj4gDQo+IGRpZmYgLS1naXQgYS9tbS9w
ZXJjcHUuYyBiL21tL3BlcmNwdS5jDQo+IGluZGV4IGI0MDExMmIyZmM1OS4uYzk5NmJjZmZiYjJh
IDEwMDY0NA0KPiAtLS0gYS9tbS9wZXJjcHUuYw0KPiArKysgYi9tbS9wZXJjcHUuYw0KPiBAQCAt
MjM0LDcgKzIzNCw3IEBAIHN0YXRpYyBpbnQgcGNwdV9jaHVua19zbG90KGNvbnN0IHN0cnVjdCBw
Y3B1X2NodW5rDQo+ICpjaHVuaykNCj4gIAlpZiAoY2h1bmstPmZyZWVfYnl0ZXMgPCBQQ1BVX01J
Tl9BTExPQ19TSVpFIHx8IGNodW5rLT5jb250aWdfYml0cw0KPiA9PSAwKQ0KPiAgCQlyZXR1cm4g
MDsNCj4gDQo+IC0JcmV0dXJuIHBjcHVfc2l6ZV90b19zbG90KGNodW5rLT5mcmVlX2J5dGVzKTsN
Cj4gKwlyZXR1cm4gcGNwdV9zaXplX3RvX3Nsb3QoY2h1bmstPmNvbnRpZ19iaXRzICogUENQVV9N
SU5fQUxMT0NfU0laRSk7DQo+ICB9DQo+IA0KPiAgLyogc2V0IHRoZSBwb2ludGVyIHRvIGEgY2h1
bmsgaW4gYSBwYWdlIHN0cnVjdCAqLw0KDQpSZXZpZXdlZC1ieTogUGVuZyBGYW4gPHBlbmcuZmFu
QG54cC5jb20+DQoNCk5vdCByZWxldmFudCB0byB0aGlzIHBhdGNoLCBhbm90aGVyIG9wdGltaXph
dGlvbiB0byBwZXJjcHUgbWlnaHQgYmUgZ29vZA0KdG8gdXNlIHBlciBjaHVuayBzcGluX2xvY2ss
IG5vdCBnb2JhbCBwY3B1X2xvY2suDQoNClRoYW5rcywNClBlbmcuDQoNCj4gLS0NCj4gMi4xNy4x
DQoNCg==

