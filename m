Return-Path: <SRS0=Ffi5=RF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3D1BC43381
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 13:32:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6CC4F20857
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 13:32:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=nxp.com header.i=@nxp.com header.b="K2H7Ksj8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6CC4F20857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nxp.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E45FE8E0003; Sat,  2 Mar 2019 08:32:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF51D8E0001; Sat,  2 Mar 2019 08:32:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CBE3A8E0003; Sat,  2 Mar 2019 08:32:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 700628E0001
	for <linux-mm@kvack.org>; Sat,  2 Mar 2019 08:32:08 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id 29so397814eds.12
        for <linux-mm@kvack.org>; Sat, 02 Mar 2019 05:32:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=qmvbEFYTsgvtV+XBJtBVXikgzmsHwl2ddbgWFKVFPCo=;
        b=OHgz4e6MYRd58fGtlxlscpSkgiOotJo8qdOQAY42sypCUzAibDYBkDRQKFazHGzqeM
         PBXHUHB18dlWlISjUqpXX4olDN9FP7G0635FTVQHrlsJxz5cRfaVVpEIejNHxusdII7+
         gJrFus2w597G9JMKs0PixFnrhTRY2QaEB1A9tslKIQL1rYRqHTQsUzJ26iJBch+wUd1i
         rdHOSzQijfrWV+UT8p66WDcFFIC533SEr66jUCrnNUWXZLZMWJ6sAGdkXldsH9ZNv03J
         5s1OiU0gmYLsLUNo9PhX7zmaGM5wJ8q6migSx1Xa53kZn6QYNaLqwNWSnpFRZq5yqpoP
         N85w==
X-Gm-Message-State: APjAAAX8Mtcpt6Q4F78f38bLJu5DWar1EdpC2O2SJ12O7jSFjs542PCw
	9ovYAnsVLQcggTADan16IfTR7ma0V4MSZy9Em/LDxPLR3U8/L7mGgOu+b+TH1WtJfQ8s+1L4JOi
	wK8YXTyDEwKQ614ovLQDu6WsfHAoqGk7OC1pOrXDsulRtwunYBMu2hCaIArQpj0EqEg==
X-Received: by 2002:a50:a4d5:: with SMTP id x21mr8325314edb.189.1551533527892;
        Sat, 02 Mar 2019 05:32:07 -0800 (PST)
X-Google-Smtp-Source: APXvYqykhxOkcTMJN3My5VRtCPZaW9d6NmLCMGjLaFCSGxQMjkeyMH6oMiUPR+znV2gpqmnePnQ8
X-Received: by 2002:a50:a4d5:: with SMTP id x21mr8325275edb.189.1551533526949;
        Sat, 02 Mar 2019 05:32:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551533526; cv=none;
        d=google.com; s=arc-20160816;
        b=o2AGVipjBY4IwFFrKlgxIfGQjmH5uU6jynfidjBWUA5WBlko19IX4kUy8Ihvqm9sDW
         1ECiikxS6x5WRhv4KD5Zz976IsKI8GHvoPqBhTMRm3pQD8FVkzRfFhhZfuk0TP9mM0jf
         yAjAHp225OCcDf7JJIUO6AbA6dzjGcphWl091LA984IMDAyqYP4kHhl02SbVR/hQ8NVy
         1WhWFP/E4jAxUD+pE5dlbOaCpjExu48vkW3mCBwpMyaPqTMopwZlBQ0QbZwwWZm2p1oc
         XTSlt5kfEx6zuIDJi/mcKV+OoNYDzTAUrTu8P7Cce28uzFIGJ67f6ZanygCCWxeM7P6h
         YF2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=qmvbEFYTsgvtV+XBJtBVXikgzmsHwl2ddbgWFKVFPCo=;
        b=MbhDtJ43+b+IptjhmfYPkx0+cxnJ/60u6b7CamsrMdidUmMeQZzDtCE3Xi3N/LZrtj
         tjThored67ddXuhFFZm1dJxNxOskesGIiNpdEyz4wnt65VvtV1St7V5LvaptCif53f/l
         liDx6z0MzJSRCzMdp56OLu7jUBnn/t/wz30/tPQy4XYdq3HE4BUO03qeo08OAgX8VSZW
         t+duzL8lVl6pwgfQeieaYNK3BdC7gzjm8BQS9n5uT45amEi3Q4YiV68GtSXmNYG9vmmS
         sAs1+bqRIE20BEJfo5t0lT7BF/U2hwUhH0MlFGA+e4ty4gMO5lu2Ztk1bFv3/GUe8nQh
         I30w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=K2H7Ksj8;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.5.40 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50040.outbound.protection.outlook.com. [40.107.5.40])
        by mx.google.com with ESMTPS id g16si241780ejs.71.2019.03.02.05.32.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Mar 2019 05:32:06 -0800 (PST)
Received-SPF: pass (google.com: domain of peng.fan@nxp.com designates 40.107.5.40 as permitted sender) client-ip=40.107.5.40;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=K2H7Ksj8;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.5.40 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nxp.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=qmvbEFYTsgvtV+XBJtBVXikgzmsHwl2ddbgWFKVFPCo=;
 b=K2H7Ksj82aGEgdV6a/OY1JJbQ1mJ6SATR+LmSwRIsSaz03OjURRTtQTBG6/861oREgPT0bWHEaQUFP12ZZNIpESXc4gjUnvbZXYljqSm1wr4evEumjHprxph85tcyy3x5lfRdxU0j3Bn15VsOKHU5M7BWRsKIk48Y/mSfvXupcc=
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com (52.135.147.15) by
 AM0PR04MB3954.eurprd04.prod.outlook.com (52.134.124.152) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.16; Sat, 2 Mar 2019 13:32:04 +0000
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185]) by AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185%5]) with mapi id 15.20.1665.019; Sat, 2 Mar 2019
 13:32:04 +0000
From: Peng Fan <peng.fan@nxp.com>
To: Dennis Zhou <dennis@kernel.org>, Tejun Heo <tj@kernel.org>, Christoph
 Lameter <cl@linux.com>
CC: Vlad Buslov <vladbu@mellanox.com>, "kernel-team@fb.com"
	<kernel-team@fb.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: RE: [PATCH 02/12] percpu: do not search past bitmap when allocating
 an area
Thread-Topic: [PATCH 02/12] percpu: do not search past bitmap when allocating
 an area
Thread-Index: AQHUzwvyQrNOCAGGWES+BJaA5orrJqX4VbWg
Date: Sat, 2 Mar 2019 13:32:04 +0000
Message-ID:
 <AM0PR04MB4481E8B4E51EB7FCFA72ABF088770@AM0PR04MB4481.eurprd04.prod.outlook.com>
References: <20190228021839.55779-1-dennis@kernel.org>
 <20190228021839.55779-3-dennis@kernel.org>
In-Reply-To: <20190228021839.55779-3-dennis@kernel.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=peng.fan@nxp.com; 
x-originating-ip: [119.31.174.68]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 2ad9fa80-996a-44d1-e7c7-08d69f1375c1
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:AM0PR04MB3954;
x-ms-traffictypediagnostic: AM0PR04MB3954:
x-microsoft-exchange-diagnostics:
 =?gb2312?B?MTtBTTBQUjA0TUIzOTU0OzIzOnY5RFVjOUdkQVhHSkRnTTQ0akt0a0U0MURI?=
 =?gb2312?B?UUNMWlRXZjV4RlZxSWRMNi9RWXU4cTltQ1hhQUdUUzJOVXhkZHdOUnhRNnl2?=
 =?gb2312?B?UERFYnc1ZmtsbFF2amJpYWd4WTErbGoydm8vTEo0OGpUaVpEY09MSnN2S0h2?=
 =?gb2312?B?dzZUaE4xckhwWFBubEZkNzduOHlGRWM1a2g3c05obFFmb0l3ckw1dVhibmtN?=
 =?gb2312?B?MTNLMEpwZVB5NjhuVVg3cGJNVFQvTktvSVk0MHg4dVBBVnZRVVFDMTQwTUw4?=
 =?gb2312?B?ZmVycG9veGpxYi9ncnFkRTB5clRaLy94TE1OMW5lNFByUG0xWjdzdmx4bjRQ?=
 =?gb2312?B?dCtCV2lEaUVvdzkvait0blM4RHJQQ2wvcWRFWGlWRDliR0NlNzh1SGZGaVl4?=
 =?gb2312?B?bDdGS29BdTFucnpkczZ6TVA0b001S21CL1ptbEpwQm1KT2xQOG00cVcxcTN3?=
 =?gb2312?B?cHB1ZmlmdWxrUk0wVHFVQm1xWXk5MTBZMGlBQlVIN0NFdGxIVS9TTTlCOVZv?=
 =?gb2312?B?MTJ1dVNEbTNzVDZIM3JkcHhFdkZUa2d1M2xtZXg0WUhKcG8wZGV5VUo5czZH?=
 =?gb2312?B?SEJQZEFWbm1TYTlXWUZtdDAvWUdBRjA5eWVUYmFwbk5zUzhuZzQ0dGxvWkdE?=
 =?gb2312?B?enpsWldOK29JeWhiMTF5amNBdDdNK3RTU0hYRmd1YUVpR0ltV0ttVHIzazZ3?=
 =?gb2312?B?aklOZ0NJUklMRUUzMWpVYzdMSk05YWZoSEo5N2tqMVFldFVYb0Nndko1RXYw?=
 =?gb2312?B?WjA4VmJNTEZXVVozQzFiUzNtK2hmdFJ4TVpBcWhuZnV2QWN3Z2FveE9UQ1dE?=
 =?gb2312?B?ZHlkY3phcFZwS2xkWldYcmpSa2FvR2ExVDNKdW1WWStERkVtZnh3VmEySGYv?=
 =?gb2312?B?M1Znc1czc2RDNmo3UFNyQ29iYlljYW12RC9xS25ER3VUN3IvTnFRRWF2R3gv?=
 =?gb2312?B?eFVORnhQWmIvS0dLaGUzOGFnSXdCR3RZWGhUSlhxRXRpdzF6VE9tOFc4eTJN?=
 =?gb2312?B?TzZMY1pVOWxZVHpnWTNxdk15blpkYUtWZXh5WGhPeEZWWEhLdW12bWtWOUtk?=
 =?gb2312?B?dnIzSmY1V0hYNUtkbFRtYWh2R3pOa05XOWUzK3Y4YUgyVHBCbFBQUXVzVnJU?=
 =?gb2312?B?N1o4R2gzMSttQnByaXZuV3dCNEh5bEIwaTU1RFBkV2JocnRhbVk4S3hMb01l?=
 =?gb2312?B?RytUU3Fqd2VrYytsSC8waWg1SE1qaHU4bVNMaEdYRWs0a25pQVNndmJzRnNB?=
 =?gb2312?B?d1NHamVwQjQwVkpnWlU4QVptalJDSkt0RjdZWFhmNlVkaDdhMm1CVXVQR2FJ?=
 =?gb2312?B?RXBtN1NGYUFqV0JUUWdYSXphb21pNzU3UlYvRFlMV0NNZjlUTWRKMGlCTTh4?=
 =?gb2312?B?cHFPWC9lbHdZQXRSOUZrQ1VCZ3VpNnVuWFp0b3pldGhTOTJjcjVFU2sybEw2?=
 =?gb2312?B?eFVuVDJTSW9uZ01VWWlVSjl1S0VEbzlYZjBqZGw1Z1M0Tkx4SHpzdmdYa2Rr?=
 =?gb2312?B?SWhVZkR0YkhuL3ZrUWdzVlNOYUtQQnBPSFZkUzlad3lUQ0ZadHFpUXlEQS94?=
 =?gb2312?B?K1BodWtuQkFGTzJNU0FwVkR3aU1HRUVGOWhOQ2F0UFN3RUJ5M09JTlVvZEdx?=
 =?gb2312?B?STNQalV5TnNSWGg2SEIwam9KcEhmd056VjNtL3FnM25OcU1ZRzY3VEVmeFdQ?=
 =?gb2312?B?QmtRbWR5MmJ4MmVhNGZWazg2TUhvUWgyeFJMNU5wendnRStUUjBQL1ljNlJq?=
 =?gb2312?B?bjRISXZRMmVKaS9kTjIwQT09?=
x-microsoft-antispam-prvs:
 <AM0PR04MB395419BC8525B4F6524AB60F88770@AM0PR04MB3954.eurprd04.prod.outlook.com>
x-forefront-prvs: 09645BAC66
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(396003)(136003)(366004)(346002)(376002)(199004)(189003)(13464003)(6116002)(4326008)(3846002)(53936002)(33656002)(14454004)(106356001)(6436002)(99286004)(105586002)(229853002)(97736004)(7736002)(55016002)(54906003)(478600001)(74316002)(6246003)(66066001)(9686003)(2906002)(305945005)(476003)(446003)(11346002)(8936002)(486006)(44832011)(86362001)(53546011)(186003)(26005)(316002)(68736007)(256004)(76176011)(52536013)(71200400001)(71190400001)(25786009)(14444005)(7696005)(110136005)(102836004)(8676002)(81166006)(81156014)(6506007)(5660300002);DIR:OUT;SFP:1101;SCL:1;SRVR:AM0PR04MB3954;H:AM0PR04MB4481.eurprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: nxp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 IUErIgxjskzL4D/Dx4w0bqGs7E9LsjEnt7E3LNO8b/ED+N/sMhWPezMOdc1ixNX8PKOU5WWQ2cZvuvaOeg269lMLiJBHve8m2ScBtqcbR2CWHmKv1YHB8gDIySD9Ey1PUwICrRFp/D4AZ0tcx4AS8mJgHV8RydDtlm2vj6P+CM3m3oEVoAw2c7TNdOPkfaYnL99sSs4ueU2cewFSWqCe55GiJcL+SyIJk/33ecSRw+SPfDntedef8dZQ3IU7zjA0hvF9UOz5UW+Fub4/xWkcrgizaFYBK1T9I6qf7CTm+YswKW4n8DVVzVSU8gb19sG+Cdpr1+lrl8ujREUjCXtfrLr7jhKYh3WT3nJ47NRWjG9sOR9MQBVNasrlRU94jLvgz875rZC4fjFIWqsryGOirjxM80VueQFvJqHxoX/8LVI=
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: nxp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 2ad9fa80-996a-44d1-e7c7-08d69f1375c1
X-MS-Exchange-CrossTenant-originalarrivaltime: 02 Mar 2019 13:32:04.7230
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 686ea1d3-bc2b-4c6f-a92c-d99c5c301635
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AM0PR04MB3954
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGkgRGVubmlzLA0KDQo+IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+IEZyb206IG93bmVy
LWxpbnV4LW1tQGt2YWNrLm9yZyBbbWFpbHRvOm93bmVyLWxpbnV4LW1tQGt2YWNrLm9yZ10gT24N
Cj4gQmVoYWxmIE9mIERlbm5pcyBaaG91DQo+IFNlbnQ6IDIwMTnE6jLUwjI4yNUgMTA6MTgNCj4g
VG86IERlbm5pcyBaaG91IDxkZW5uaXNAa2VybmVsLm9yZz47IFRlanVuIEhlbyA8dGpAa2VybmVs
Lm9yZz47IENocmlzdG9waA0KPiBMYW1ldGVyIDxjbEBsaW51eC5jb20+DQo+IENjOiBWbGFkIEJ1
c2xvdiA8dmxhZGJ1QG1lbGxhbm94LmNvbT47IGtlcm5lbC10ZWFtQGZiLmNvbTsNCj4gbGludXgt
bW1Aa3ZhY2sub3JnOyBsaW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnDQo+IFN1YmplY3Q6IFtQ
QVRDSCAwMi8xMl0gcGVyY3B1OiBkbyBub3Qgc2VhcmNoIHBhc3QgYml0bWFwIHdoZW4gYWxsb2Nh
dGluZyBhbg0KPiBhcmVhDQo+IA0KPiBwY3B1X2ZpbmRfYmxvY2tfZml0KCkgZ3VhcmFudGVlcyB0
aGF0IGEgZml0IGlzIGZvdW5kIHdpdGhpbg0KPiBQQ1BVX0JJVE1BUF9CTE9DS19CSVRTLiBJdGVy
YXRpb24gaXMgdXNlZCB0byBkZXRlcm1pbmUgdGhlIGZpcnN0IGZpdCBhcyBpdA0KPiBjb21wYXJl
cyBhZ2FpbnN0IHRoZSBibG9jaydzIGNvbnRpZ19oaW50LiBUaGlzIGNhbiBsZWFkIHRvIGluY29y
cmVjdGx5IHNjYW5uaW5nDQo+IHBhc3QgdGhlIGVuZCBvZiB0aGUgYml0bWFwLiBUaGUgYmVoYXZp
b3Igd2FzIG9rYXkgZ2l2ZW4gdGhlIGNoZWNrIGFmdGVyIGZvcg0KPiBiaXRfb2ZmID49IGVuZCBh
bmQgdGhlIGNvcnJlY3RuZXNzIG9mIHRoZSBoaW50cyBmcm9tIHBjcHVfZmluZF9ibG9ja19maXQo
KS4NCj4gDQo+IFRoaXMgcGF0Y2ggZml4ZXMgdGhpcyBieSBib3VuZGluZyB0aGUgZW5kIG9mZnNl
dCBieSB0aGUgbnVtYmVyIG9mIGJpdHMgaW4gYQ0KPiBjaHVuay4NCj4gDQo+IFNpZ25lZC1vZmYt
Ynk6IERlbm5pcyBaaG91IDxkZW5uaXNAa2VybmVsLm9yZz4NCj4gLS0tDQo+ICBtbS9wZXJjcHUu
YyB8IDMgKystDQo+ICAxIGZpbGUgY2hhbmdlZCwgMiBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9u
KC0pDQo+IA0KPiBkaWZmIC0tZ2l0IGEvbW0vcGVyY3B1LmMgYi9tbS9wZXJjcHUuYw0KPiBpbmRl
eCA1M2JkNzlhNjE3YjEuLjY5Y2E1MWQyMzhiNSAxMDA2NDQNCj4gLS0tIGEvbW0vcGVyY3B1LmMN
Cj4gKysrIGIvbW0vcGVyY3B1LmMNCj4gQEAgLTk4OCw3ICs5ODgsOCBAQCBzdGF0aWMgaW50IHBj
cHVfYWxsb2NfYXJlYShzdHJ1Y3QgcGNwdV9jaHVuayAqY2h1bmssDQo+IGludCBhbGxvY19iaXRz
LA0KPiAgCS8qDQo+ICAJICogU2VhcmNoIHRvIGZpbmQgYSBmaXQuDQo+ICAJICovDQo+IC0JZW5k
ID0gc3RhcnQgKyBhbGxvY19iaXRzICsgUENQVV9CSVRNQVBfQkxPQ0tfQklUUzsNCj4gKwllbmQg
PSBtaW5fdChpbnQsIHN0YXJ0ICsgYWxsb2NfYml0cyArIFBDUFVfQklUTUFQX0JMT0NLX0JJVFMs
DQo+ICsJCSAgICBwY3B1X2NodW5rX21hcF9iaXRzKGNodW5rKSk7DQo+ICAJYml0X29mZiA9IGJp
dG1hcF9maW5kX25leHRfemVyb19hcmVhKGNodW5rLT5hbGxvY19tYXAsIGVuZCwgc3RhcnQsDQo+
ICAJCQkJCSAgICAgYWxsb2NfYml0cywgYWxpZ25fbWFzayk7DQo+ICAJaWYgKGJpdF9vZmYgPj0g
ZW5kKQ0KPiAtLQ0KDQpGcm9tIHBjcHVfYWxsb2NfYXJlYSBpdHNlbGYsIEkgdGhpbmsgdGhpcyBp
cyBjb3JyZWN0IHRvIGF2b2lkIGJpdG1hcF9maW5kX25leHRfemVyb19hcmVhDQpzY2FuIHBhc3Qg
dGhlIGJvdW5kYXJpZXMgb2YgYWxsb2NfbWFwLCBzbw0KDQpSZXZpZXdlZC1ieTogUGVuZyBGYW4g
PHBlbmcuZmFuQG54cC5jb20+DQoNClRoZXJlIGFyZSBhIGZldyBwb2ludHMgSSBkaWQgbm90IHVu
ZGVyc3RhbmQgd2VsbCwNClBlciB1bmRlcnN0YW5kaW5nIHBjcHVfZmluZF9ibG9ja19maXQgaXMg
dG8gZmluZCB0aGUgZmlyc3QgYml0IG9mZiBpbiBhIGNodW5rIHdoaWNoIGNvdWxkIHNhdGlzZnkN
CnRoZSBiaXRzIGFsbG9jYXRpb24sIHNvIGJpdHMgbWlnaHQgYmUgbGFyZ2VyIHRoYW4gUENQVV9C
SVRNQVBfQkxPQ0tfQklUUy4gQW5kIGlmDQpwY3B1X2ZpbmRfYmxvY2tfZml0IHJldHVybnMgYSBn
b29kIG9mZiwgaXQgbWVhbnMgdGhlcmUgaXMgYSBhcmVhIGluIHRoZSBjaHVuayBjb3VsZCBzYXRp
c2Z5DQp0aGUgYml0cyBhbGxvY2F0aW9uLCB0aGVuIHRoZSBmb2xsb3dpbmcgcGNwdV9hbGxvY19h
cmVhIHdpbGwgbm90IHNjYW4gcGFzdCB0aGUgYm91bmRhcmllcyBvZg0KYWxsb2NfbWFwLCByaWdo
dD8NCg0KVGhhbmtzLA0KUGVuZy4NCg0KPiAyLjE3LjENCg0K

