Return-Path: <SRS0=Ffi5=RF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A0C6C43381
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 13:55:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3056820838
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 13:55:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=nxp.com header.i=@nxp.com header.b="oWoAu67M"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3056820838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nxp.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE7BA8E0003; Sat,  2 Mar 2019 08:55:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B98AC8E0001; Sat,  2 Mar 2019 08:55:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A394B8E0003; Sat,  2 Mar 2019 08:55:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3BAD08E0001
	for <linux-mm@kvack.org>; Sat,  2 Mar 2019 08:55:58 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id h37so425783eda.7
        for <linux-mm@kvack.org>; Sat, 02 Mar 2019 05:55:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=J2XtwoDe+A9DhM99DdpQLjpj7UMgRlhs/k4f5hp39Dk=;
        b=H064hdrmu3odleS1rd/q5ImaOCrKYWYtWxYgUQmiw6hvAjvoOArJC3sAXtRCi7fa2j
         8o1seAGEjFFOursCMLB178GrA0kfrQ/RfbaVWm/whndGjFTX7/7rpYkAKh2yKQXMUVSM
         tzD93/WKwKMQqUgJ6epgwq88aj8ZXipmEmzjWRbE3gFznMBV/2cptmlc3wU6FKN23TcZ
         otYu+RKyyI4KGrvObdL7vlvJGw0H1lUPqRZCz3EAJXiH4TKDiB0d1WshQAsDA0nUUjWq
         YQOGHJkhkaaN4kaa90fIe8t9gX9iV1931gsU+lKdETiu8CsDsCflGhvjTNeBOCKoIL+m
         PH4g==
X-Gm-Message-State: APjAAAWfcoVBKkRe4PEiUMht10erHVfFTkdrTsSdjW+aPh6YY3AYrt6N
	HYMOuqrn584vaWI3pl7Y7tahdQpVN5H6mZzLi80h04+XCFVh4wflwMDLOsLoWq/jTrztugfqapp
	lHWLgCiAtJ3Yd+hfA7P6To8REVOwZ4z1KrXcl+wrdVzCPAsLZBG0ywgpv3AiTWPEKPw==
X-Received: by 2002:a17:906:5781:: with SMTP id k1mr6788887ejq.34.1551534957741;
        Sat, 02 Mar 2019 05:55:57 -0800 (PST)
X-Google-Smtp-Source: APXvYqymQVHI70rsnkhKNJDJyE4MLWSv/2dx9psl8wmrcSE+XJx+TjH4bEGIhF97AlWLILiheeOV
X-Received: by 2002:a17:906:5781:: with SMTP id k1mr6788850ejq.34.1551534956862;
        Sat, 02 Mar 2019 05:55:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551534956; cv=none;
        d=google.com; s=arc-20160816;
        b=aGP17/Kc2xpWHfG4FYY8t37wrZ2lAG1JwFYGo3tPeJK4CTnoRxbiRmP35KdSMXg1mr
         O+aDtMcYe2VsfhTYVNvP47pgpaC0hIcJxMx9YILClIj7sDGcmLxG94xFoOvAl3L6gIMo
         9+M4VGcN0VHgqyz+Zi9mfyuGzhWYMPxjBMKExkchBrh2RzY4c3x7YA+BsNPZQQIltPX+
         YdjqJo7CeWuxupGVx34F+O83VMNmhEQExJHOgqi1YC5gdofKcOTcEsC2ni/6lkcc2nux
         MVkMgl1PL+7MlQE2By4CEs3FXU1VbA0xW+4GOA3V7/Zn6aK3+4QzIb2+OZ+lxx9qsKSG
         qdhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=J2XtwoDe+A9DhM99DdpQLjpj7UMgRlhs/k4f5hp39Dk=;
        b=BYbUoWwXh59qAT+ZSToPxBe6yMYpMWlM6yxffCustsDU8T1vOntlRejUui6n04lHjN
         JqJTKwy/rQyPOV66StXnnNaNYQ/eCqgtnoXNIo+yK6ImsCPdOoRNThGlq3txd9aUhQ/t
         pn8yWKBPIprGnhH4G/q0B2tRdwUb6magnhS94o3H9C9Lt9VqssrPev1/7KTdlVI7y1IZ
         8mlJtAJFi52JWQ9oYmdIUFHyL11WuVSUQ3chg45WjN0X0h7CVEtqfrM5Lkv0JjU9O2T/
         O8adeKgLUIAv+uOSXbuDbQC2o0onppX8vxZ+JncDJDWVSwlNOTrwqzpX3y7UfwpAoCXK
         EKzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=oWoAu67M;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.2.86 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20086.outbound.protection.outlook.com. [40.107.2.86])
        by mx.google.com with ESMTPS id c54si443376eda.324.2019.03.02.05.55.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Mar 2019 05:55:56 -0800 (PST)
Received-SPF: pass (google.com: domain of peng.fan@nxp.com designates 40.107.2.86 as permitted sender) client-ip=40.107.2.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=oWoAu67M;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.2.86 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nxp.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=J2XtwoDe+A9DhM99DdpQLjpj7UMgRlhs/k4f5hp39Dk=;
 b=oWoAu67M3H+JOZH9JKLdPPQDE/HJFohAHPxY6c2zsz/KfrTh9yk7/ui+/JZZ6xE9XyQcJKC15rSZyfqfXEW0M2utMIk1bGw/wrdbBwKVZdD+A/Po6xiiEMze/AL5REHxVEhrgKa7pLW2Y+7PhZ7Vp2rm19vfSD6vPvZkZFxDCmg=
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com (52.135.147.15) by
 AM0PR04MB4226.eurprd04.prod.outlook.com (52.134.91.24) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.16; Sat, 2 Mar 2019 13:55:55 +0000
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185]) by AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185%5]) with mapi id 15.20.1665.019; Sat, 2 Mar 2019
 13:55:55 +0000
From: Peng Fan <peng.fan@nxp.com>
To: Dennis Zhou <dennis@kernel.org>, Tejun Heo <tj@kernel.org>, Christoph
 Lameter <cl@linux.com>
CC: Vlad Buslov <vladbu@mellanox.com>, "kernel-team@fb.com"
	<kernel-team@fb.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: RE: [PATCH 05/12] percpu: relegate chunks unusable when failing small
 allocations
Thread-Topic: [PATCH 05/12] percpu: relegate chunks unusable when failing
 small allocations
Thread-Index: AQHUzwv3B7bPPhTIqESPGGL2rz7Di6X4X1uA
Date: Sat, 2 Mar 2019 13:55:54 +0000
Message-ID:
 <AM0PR04MB4481502C6D96166F594994CA88770@AM0PR04MB4481.eurprd04.prod.outlook.com>
References: <20190228021839.55779-1-dennis@kernel.org>
 <20190228021839.55779-6-dennis@kernel.org>
In-Reply-To: <20190228021839.55779-6-dennis@kernel.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=peng.fan@nxp.com; 
x-originating-ip: [119.31.174.68]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 52eebccd-8d72-4532-c6e5-08d69f16ca49
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:AM0PR04MB4226;
x-ms-traffictypediagnostic: AM0PR04MB4226:
x-microsoft-exchange-diagnostics:
 =?gb2312?B?MTtBTTBQUjA0TUI0MjI2OzIzOm1qS21HUTJFWEtoM05Ja0kwK2FzWkFBVGF6?=
 =?gb2312?B?azd3UmprdEUvV0NUUzJmUzRrQzlqcGk3U2NXSFNzeE1GY3hWV29Kc2M5THJv?=
 =?gb2312?B?TllVenVPYUpPb0V3aWliejJYQ2xSWE02RGpvdFFIWS9oUFdZTEdVNXJpV1hu?=
 =?gb2312?B?elBEOHd0aldFaklsV1piNitoRzgvTDhpbDdDZDdDbEF6Ymtoc3dwQjJXUzk2?=
 =?gb2312?B?czlocithZGR4TTAzMzJWRGQ4WkNacEJmSDBpNGM0VktKRW5wQ1JyU25VOVlF?=
 =?gb2312?B?elZ2RC9pMXc1bjY2V2QremhBUm5TME91OCs1VldHMFI0R1pqRFRQQ1lvL1lT?=
 =?gb2312?B?Tm9ydzFsK0RlL29kYmV4Y2lOc1ZVYVNNQnB3UHQ2dHZVU1ZHUmVDSWc3UTM2?=
 =?gb2312?B?VGJsUTdxTU1TTzNlSGFzUVEwSk9NMmVyQUpCRFdWVmNzNklxeU92aVJsQTNa?=
 =?gb2312?B?MGl3V2JKb1J1aDF3T0NwUXo1Sk96Yjg2ZGRuV0lBS2wvT0JWTktNc2hHNmtl?=
 =?gb2312?B?cTBEUHVNSmJOV0E0YzMzTDc3YXQyOGowa0VWU0V3d0VRUTgxZWFHc1NQSkFx?=
 =?gb2312?B?WXlMTnRTVEZSejR0VkVMWlBFVUhHblV5QStKeUF5NFF1Qkw3SFNKQ2RBN1R0?=
 =?gb2312?B?TFowUWZpVHJyYTNpUGVNNmhaYUNjU3NDVlZqQk5qQmxkV2ZtUmM3cC9PRG1U?=
 =?gb2312?B?bERQVlpiMXhlMHFGbWhZYkRQSmE2MnZzVklxVUdTWC9BVnBCNmlwdmlNRXQ5?=
 =?gb2312?B?Wk5hZFZiSGx1V0lqbFpXSUxZQVlKWUlmR0ZoSjU2TWFvSWd6Sjl5ZkdYTS9x?=
 =?gb2312?B?bkpqRG5aRXltWG1PZlpITVAyMWoyZ1hzU0JBNVY5cGJkQVNqODB6S2hpRDV6?=
 =?gb2312?B?WWJCV00wdGJvU0VwYVFNVGlxY0MwWjI2QXBzT0dlalRKOExMOFJSMU5sWmhO?=
 =?gb2312?B?UzhYQ2E2bFcwT3QwQUlYOElOS2tFYzBQUC8zVDc4aUlBd2JuS2FpZ2lCMGx3?=
 =?gb2312?B?RmFEU0E3QWhyb1BNVDEvL2NySDFuMU5ITElJUk02a0J2aTd5d1JJWmRjdkVV?=
 =?gb2312?B?c252K0dHbmhCaFArZCs4d1AwcXM5VTUraFppaERxQTFWN0x4VEdEblFXVS8v?=
 =?gb2312?B?MUM5UFZvT1Fqb1ROZXVJWGZBUERadHgvWS91U2pkMGZ0eG1VYU4rUVI1Y0xp?=
 =?gb2312?B?dWdnUVY5WXFuM1dQUUpTK0J6VERhVjBydlRBS2FNSXZia3RrQU42SVFoSHM3?=
 =?gb2312?B?RGZSR3hYUUFyY1lNM0dVWVVxdEtYQlVlQzFmSGlMT3hYUnZmeS9oUCtxS1pt?=
 =?gb2312?B?YW1TUDJjbWg4c1BuT2R6eE9Feldod1ZsN3pqMVhqNlFnTlpIcEhuT0RFMjJq?=
 =?gb2312?B?N0xVN1lSRFRxZS81NVZqNE1udCtBZHZmZ1krMytWOFZmbm5pUVVQR1lFQ0JT?=
 =?gb2312?B?NHhPdDVSNVpPZVArZEQvb3F5M2dTcTk0d2RFT1FCTlFBQ3duTndCWkx6cFdm?=
 =?gb2312?B?N2FYSGVDTkdnN1hmVVNCWWhTUFZhUFJPMGZoZHlVZXZOM1BYd2ZWREl4S05Q?=
 =?gb2312?B?VDNGS1FxNWYxTjVMRTZ1Z0xVUXl2WU0xRXpwNmt3WjlFSW1KK1RmNjBYM3FK?=
 =?gb2312?B?N2YwNU1KZTJuN2UrS3dyak1aeERpV2c1UEJaVnpuWmxGL1JSdk41aHFwN1ZX?=
 =?gb2312?B?TU9SQnJTdEJVMnpZQUhqTnNkV3QzOE5JZTF5NjhzZU95eFlQL2d5ZzY3dk5X?=
 =?gb2312?B?ZFlvZ3ZjK0NWZERPQ3l1dz09?=
x-microsoft-antispam-prvs:
 <AM0PR04MB4226273981240CA20C8DD53688770@AM0PR04MB4226.eurprd04.prod.outlook.com>
x-forefront-prvs: 09645BAC66
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(366004)(136003)(376002)(396003)(39860400002)(346002)(199004)(189003)(13464003)(9686003)(55016002)(305945005)(26005)(76176011)(229853002)(7696005)(33656002)(316002)(53546011)(66066001)(6246003)(7736002)(5660300002)(53936002)(6506007)(105586002)(106356001)(99286004)(68736007)(186003)(6436002)(52536013)(25786009)(446003)(3846002)(8936002)(6116002)(8676002)(81156014)(81166006)(97736004)(74316002)(54906003)(14444005)(71190400001)(4326008)(71200400001)(102836004)(478600001)(86362001)(11346002)(476003)(44832011)(110136005)(2906002)(486006)(256004)(14454004);DIR:OUT;SFP:1101;SCL:1;SRVR:AM0PR04MB4226;H:AM0PR04MB4481.eurprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: nxp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 2kVn5erfSjQAobq3iIkiXafSHg/PqMWTa7lcpcaSZgFDriC8fVRSTH7ezeVkCeD1OQMR+bRJxkqbuA9kYdHeP9ULcIYikwghqfVgSJuSbpFFS59YPlrxyA2sk+Oje6Y+BaLrhbe/oDFFtCARIJh1u8LxaIUooAzkn00OYtz56SLOpX+y1UrdYGwrtGQh8oZPTfro8vq9hWYwJmA12l8M5i1f7snTjs5GBDwrr0no6/e2wCFW971/u0nkQgIJUGPLJwcp7xFP7KKVY/9e9xUfnxLJ0vos1WFTIb2JUBQK98HWB2kz5Nh0LiC56hnSgWaYR298C7blkbUzh2L70PemwHf61sTDCVaVORxSg981CZuBR8Usex17OPg7kN+IsdApPMS0JJa1VfYkoQ7lllK1A6C5EA5mE5wjoGCMqe/p8H8=
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: nxp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 52eebccd-8d72-4532-c6e5-08d69f16ca49
X-MS-Exchange-CrossTenant-originalarrivaltime: 02 Mar 2019 13:55:55.0072
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 686ea1d3-bc2b-4c6f-a92c-d99c5c301635
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AM0PR04MB4226
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGkgRGVubmlzLA0KDQo+IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+IEZyb206IG93bmVy
LWxpbnV4LW1tQGt2YWNrLm9yZyBbbWFpbHRvOm93bmVyLWxpbnV4LW1tQGt2YWNrLm9yZ10gT24N
Cj4gQmVoYWxmIE9mIERlbm5pcyBaaG91DQo+IFNlbnQ6IDIwMTnE6jLUwjI4yNUgMTA6MTkNCj4g
VG86IERlbm5pcyBaaG91IDxkZW5uaXNAa2VybmVsLm9yZz47IFRlanVuIEhlbyA8dGpAa2VybmVs
Lm9yZz47IENocmlzdG9waA0KPiBMYW1ldGVyIDxjbEBsaW51eC5jb20+DQo+IENjOiBWbGFkIEJ1
c2xvdiA8dmxhZGJ1QG1lbGxhbm94LmNvbT47IGtlcm5lbC10ZWFtQGZiLmNvbTsNCj4gbGludXgt
bW1Aa3ZhY2sub3JnOyBsaW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnDQo+IFN1YmplY3Q6IFtQ
QVRDSCAwNS8xMl0gcGVyY3B1OiByZWxlZ2F0ZSBjaHVua3MgdW51c2FibGUgd2hlbiBmYWlsaW5n
IHNtYWxsDQo+IGFsbG9jYXRpb25zDQo+IA0KPiBJbiBjZXJ0YWluIGNhc2VzLCByZXF1ZXN0b3Jz
IG9mIHBlcmNwdSBtZW1vcnkgbWF5IHdhbnQgc3BlY2lmaWMgYWxpZ25tZW50cy4NCj4gSG93ZXZl
ciwgaXQgaXMgcG9zc2libGUgdG8gZW5kIHVwIGluIHNpdHVhdGlvbnMgd2hlcmUgdGhlIGNvbnRp
Z19oaW50IG1hdGNoZXMsDQo+IGJ1dCB0aGUgYWxpZ25tZW50IGRvZXMgbm90LiBUaGlzIGNhdXNl
cyBleGNlc3Mgc2Nhbm5pbmcgb2YgY2h1bmtzIHRoYXQgd2lsbCBmYWlsLg0KPiBUbyBwcmV2ZW50
IHRoaXMsIGlmIGEgc21hbGwgYWxsb2NhdGlvbiBmYWlscyAoPCAzMkIpLCB0aGUgY2h1bmsgaXMg
bW92ZWQgdG8gdGhlDQo+IGVtcHR5IGxpc3QuIE9uY2UgYW4gYWxsb2NhdGlvbiBpcyBmcmVlZCBm
cm9tIHRoYXQgY2h1bmssIGl0IGlzIHBsYWNlZCBiYWNrIGludG8NCj4gcm90YXRpb24uDQo+IA0K
PiBTaWduZWQtb2ZmLWJ5OiBEZW5uaXMgWmhvdSA8ZGVubmlzQGtlcm5lbC5vcmc+DQo+IC0tLQ0K
PiAgbW0vcGVyY3B1LmMgfCAzNSArKysrKysrKysrKysrKysrKysrKysrKysrKy0tLS0tLS0tLQ0K
PiAgMSBmaWxlIGNoYW5nZWQsIDI2IGluc2VydGlvbnMoKyksIDkgZGVsZXRpb25zKC0pDQo+IA0K
PiBkaWZmIC0tZ2l0IGEvbW0vcGVyY3B1LmMgYi9tbS9wZXJjcHUuYw0KPiBpbmRleCBjOTk2YmNm
ZmJiMmEuLjNkN2RlZWNlOTU1NiAxMDA2NDQNCj4gLS0tIGEvbW0vcGVyY3B1LmMNCj4gKysrIGIv
bW0vcGVyY3B1LmMNCj4gQEAgLTk0LDYgKzk0LDggQEANCj4gDQo+ICAvKiB0aGUgc2xvdHMgYXJl
IHNvcnRlZCBieSBmcmVlIGJ5dGVzIGxlZnQsIDEtMzEgYnl0ZXMgc2hhcmUgdGhlIHNhbWUgc2xv
dCAqLw0KPiAgI2RlZmluZSBQQ1BVX1NMT1RfQkFTRV9TSElGVAkJNQ0KPiArLyogY2h1bmtzIGlu
IHNsb3RzIGJlbG93IHRoaXMgYXJlIHN1YmplY3QgdG8gYmVpbmcgc2lkZWxpbmVkIG9uIGZhaWxl
ZCBhbGxvYyAqLw0KPiArI2RlZmluZSBQQ1BVX1NMT1RfRkFJTF9USFJFU0hPTEQJMw0KPiANCj4g
ICNkZWZpbmUgUENQVV9FTVBUWV9QT1BfUEFHRVNfTE9XCTINCj4gICNkZWZpbmUgUENQVV9FTVBU
WV9QT1BfUEFHRVNfSElHSAk0DQo+IEBAIC00ODgsNiArNDkwLDIyIEBAIHN0YXRpYyB2b2lkIHBj
cHVfbWVtX2ZyZWUodm9pZCAqcHRyKQ0KPiAgCWt2ZnJlZShwdHIpOw0KPiAgfQ0KPiANCj4gK3N0
YXRpYyB2b2lkIF9fcGNwdV9jaHVua19tb3ZlKHN0cnVjdCBwY3B1X2NodW5rICpjaHVuaywgaW50
IHNsb3QsDQo+ICsJCQkgICAgICBib29sIG1vdmVfZnJvbnQpDQo+ICt7DQo+ICsJaWYgKGNodW5r
ICE9IHBjcHVfcmVzZXJ2ZWRfY2h1bmspIHsNCj4gKwkJaWYgKG1vdmVfZnJvbnQpDQo+ICsJCQls
aXN0X21vdmUoJmNodW5rLT5saXN0LCAmcGNwdV9zbG90W3Nsb3RdKTsNCj4gKwkJZWxzZQ0KPiAr
CQkJbGlzdF9tb3ZlX3RhaWwoJmNodW5rLT5saXN0LCAmcGNwdV9zbG90W3Nsb3RdKTsNCj4gKwl9
DQo+ICt9DQo+ICsNCj4gK3N0YXRpYyB2b2lkIHBjcHVfY2h1bmtfbW92ZShzdHJ1Y3QgcGNwdV9j
aHVuayAqY2h1bmssIGludCBzbG90KSB7DQo+ICsJX19wY3B1X2NodW5rX21vdmUoY2h1bmssIHNs
b3QsIHRydWUpOw0KPiArfQ0KPiArDQo+ICAvKioNCj4gICAqIHBjcHVfY2h1bmtfcmVsb2NhdGUg
LSBwdXQgY2h1bmsgaW4gdGhlIGFwcHJvcHJpYXRlIGNodW5rIHNsb3QNCj4gICAqIEBjaHVuazog
Y2h1bmsgb2YgaW50ZXJlc3QNCj4gQEAgLTUwNSwxMiArNTIzLDggQEAgc3RhdGljIHZvaWQgcGNw
dV9jaHVua19yZWxvY2F0ZShzdHJ1Y3QgcGNwdV9jaHVuaw0KPiAqY2h1bmssIGludCBvc2xvdCkg
IHsNCj4gIAlpbnQgbnNsb3QgPSBwY3B1X2NodW5rX3Nsb3QoY2h1bmspOw0KPiANCj4gLQlpZiAo
Y2h1bmsgIT0gcGNwdV9yZXNlcnZlZF9jaHVuayAmJiBvc2xvdCAhPSBuc2xvdCkgew0KPiAtCQlp
ZiAob3Nsb3QgPCBuc2xvdCkNCj4gLQkJCWxpc3RfbW92ZSgmY2h1bmstPmxpc3QsICZwY3B1X3Ns
b3RbbnNsb3RdKTsNCj4gLQkJZWxzZQ0KPiAtCQkJbGlzdF9tb3ZlX3RhaWwoJmNodW5rLT5saXN0
LCAmcGNwdV9zbG90W25zbG90XSk7DQo+IC0JfQ0KPiArCWlmIChvc2xvdCAhPSBuc2xvdCkNCj4g
KwkJX19wY3B1X2NodW5rX21vdmUoY2h1bmssIG5zbG90LCBvc2xvdCA8IG5zbG90KTsNCj4gIH0N
Cj4gDQo+ICAvKioNCj4gQEAgLTEzODEsNyArMTM5NSw3IEBAIHN0YXRpYyB2b2lkIF9fcGVyY3B1
ICpwY3B1X2FsbG9jKHNpemVfdCBzaXplLCBzaXplX3QNCj4gYWxpZ24sIGJvb2wgcmVzZXJ2ZWQs
DQo+ICAJYm9vbCBpc19hdG9taWMgPSAoZ2ZwICYgR0ZQX0tFUk5FTCkgIT0gR0ZQX0tFUk5FTDsN
Cj4gIAlib29sIGRvX3dhcm4gPSAhKGdmcCAmIF9fR0ZQX05PV0FSTik7DQo+ICAJc3RhdGljIGlu
dCB3YXJuX2xpbWl0ID0gMTA7DQo+IC0Jc3RydWN0IHBjcHVfY2h1bmsgKmNodW5rOw0KPiArCXN0
cnVjdCBwY3B1X2NodW5rICpjaHVuaywgKm5leHQ7DQo+ICAJY29uc3QgY2hhciAqZXJyOw0KPiAg
CWludCBzbG90LCBvZmYsIGNwdSwgcmV0Ow0KPiAgCXVuc2lnbmVkIGxvbmcgZmxhZ3M7DQo+IEBA
IC0xNDQzLDExICsxNDU3LDE0IEBAIHN0YXRpYyB2b2lkIF9fcGVyY3B1ICpwY3B1X2FsbG9jKHNp
emVfdCBzaXplLA0KPiBzaXplX3QgYWxpZ24sIGJvb2wgcmVzZXJ2ZWQsDQo+ICByZXN0YXJ0Og0K
PiAgCS8qIHNlYXJjaCB0aHJvdWdoIG5vcm1hbCBjaHVua3MgKi8NCj4gIAlmb3IgKHNsb3QgPSBw
Y3B1X3NpemVfdG9fc2xvdChzaXplKTsgc2xvdCA8IHBjcHVfbnJfc2xvdHM7IHNsb3QrKykgew0K
PiAtCQlsaXN0X2Zvcl9lYWNoX2VudHJ5KGNodW5rLCAmcGNwdV9zbG90W3Nsb3RdLCBsaXN0KSB7
DQo+ICsJCWxpc3RfZm9yX2VhY2hfZW50cnlfc2FmZShjaHVuaywgbmV4dCwgJnBjcHVfc2xvdFtz
bG90XSwgbGlzdCkgew0KPiAgCQkJb2ZmID0gcGNwdV9maW5kX2Jsb2NrX2ZpdChjaHVuaywgYml0
cywgYml0X2FsaWduLA0KPiAgCQkJCQkJICBpc19hdG9taWMpOw0KPiAtCQkJaWYgKG9mZiA8IDAp
DQo+ICsJCQlpZiAob2ZmIDwgMCkgew0KPiArCQkJCWlmIChzbG90IDwgUENQVV9TTE9UX0ZBSUxf
VEhSRVNIT0xEKQ0KPiArCQkJCQlwY3B1X2NodW5rX21vdmUoY2h1bmssIDApOw0KPiAgCQkJCWNv
bnRpbnVlOw0KPiArCQkJfQ0KPiANCj4gIAkJCW9mZiA9IHBjcHVfYWxsb2NfYXJlYShjaHVuaywg
Yml0cywgYml0X2FsaWduLCBvZmYpOw0KPiAgCQkJaWYgKG9mZiA+PSAwKQ0KDQpGb3IgdGhlIGNv
ZGU6IFJldmlld2VkLWJ5OiBQZW5nIEZhbiA8cGVuZy5mYW5AbnhwLmNvbT4NCg0KQnV0IEkgZGlk
IG5vdCB1bmRlcnN0YW5kIHdlbGwgd2h5IGNob29zZSAzMkI/IElmIHRoZXJlIGFyZQ0KbW9yZSBp
bmZvcm1hdGlvbiwgYmV0dGVyIHB1dCBpbiBjb21taXQgbG9nLg0KDQpUaGFua3MsDQpQZW5nLg0K
DQoNCj4gLS0NCj4gMi4xNy4xDQoNCg==

