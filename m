Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E801C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 14:01:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D2F6222B0
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 14:01:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=oneplus.com header.i=@oneplus.com header.b="L6ciJmOQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D2F6222B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=oneplus.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8433B8E00E8; Mon, 11 Feb 2019 09:01:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F37F8E00C3; Mon, 11 Feb 2019 09:01:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6BD8C8E00E8; Mon, 11 Feb 2019 09:01:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 28BA58E00C3
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 09:01:44 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id 12so9400486plb.18
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 06:01:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=lo+Nw78TKhlhcoC/rXc93j6zWIDVsC/4u3zpOh+BXRI=;
        b=EpFS0KR99PGJgAEpyd4PXX8ebedo7ghreG7pGVC0Fy+IG97oY4fG1fC9vlEUYygIf4
         BlLH1h0wjzJqaulYWXi7TlYVAqITlsGVnzEXOQwUVvElvYPGiQ5mBhSoZUYh17I+qFl9
         JW2xQzV8MPK9lyBRZ9W5C474weIDFZ2jlRXs7QwIjlgjlNwtPjzXcnyJoU+fgO3o6gwu
         M3l4AO+2ZD99YQBdMmTeHsdJTSvhCeLJnKYyrSpXNgKeJS/b02k+o5VclTuHJ0efxv/I
         PX3KNEXHsAMjBbF+2I/JNbIAMFAm5CgNPt4scHmPREQd10TCJeDyiRqV8mpe9JS9Ynrd
         v2yg==
X-Gm-Message-State: AHQUAuZ+arPdCT9ln8s/vmFEf2MQKc1OLpm94VeJgZhXQqEWuUCtlXYl
	UphMGVd4xVsq/m0pt10DcpIxdkhh5Ij715udcvUdE+RMbXM1wmEER0VSTePxKAE9ILHsDAhvdpF
	XYzDNep3MMqZaTM34UKSZJJKD/Yu8sfFLY/EOr0Fi5XzHAXXnH42J3sc/L7nIYflaSA==
X-Received: by 2002:a62:6dc7:: with SMTP id i190mr36811549pfc.166.1549893703847;
        Mon, 11 Feb 2019 06:01:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbGLLFjPH8PLQGDQViziakGCXgtknXo2HKUxtKXLEGBMu0nxQJcOeX4BFhm/vnffLuQTCX2
X-Received: by 2002:a62:6dc7:: with SMTP id i190mr36811509pfc.166.1549893703230;
        Mon, 11 Feb 2019 06:01:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549893703; cv=none;
        d=google.com; s=arc-20160816;
        b=FV3WAEerljxcNLXanpW4SkXJEhrff/HYaBwBEGjWWg0anrYSKIr3hpzATSsttHa7Xe
         mDA19mXsXCHNtFPGuErQy+7i6/ACnb4BoymaleFbiw0cAULEdPCUr/kPLjXs6rWwZzfl
         WAZXZFwNnp3UEEiVUXRkH6tu4V1B2zCumGvn0PaVPVU1H6tuAQAwtCVgzsL1dIVNJpY5
         CbTMGYY26JVBjVumBGhOMAv3yGDJevnN1pl794KQ71yNiJfcvLrbxzPJVMsh5UTYjW58
         Uad93m/5ROOGOW7MKcV2iRSWtH6IZGm86hHwaNVFcbnVoJw2nSvTDZikacX51rd2Y65i
         JNuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=lo+Nw78TKhlhcoC/rXc93j6zWIDVsC/4u3zpOh+BXRI=;
        b=M964rE1KW/BoZBunjEyhg72mSNRg8fjFVDfsJok0NegfTT7cUZihOm6gvxhFjJTrc7
         /jQP0DMWwZS+HYmOD2n/WqMZ5q9t7f9nhh60T8QR9gEWEv8xeXUnjf7PxK+MAq0SrpWM
         tfEAYHnJHZcZlh/BMJ51YNiIESpr7w8D6XawMHGO+ZiRTkktsVeC94cHbkYQj6b9IiZL
         nU++Pt6aGEaIizdXat4/4YAZH4mhXEhXVqp9W21ArOV9DI7LGc+Rg7NtMH6in1Jg36tN
         DyGo26tD9ILbFE/rzb+J7xX8ZK+F+SaO83gfEejgcwd9eC5jiCjCd0c3dLX2EhYxcAR+
         eWWw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oneplus.com header.s=selector1 header.b=L6ciJmOQ;
       spf=pass (google.com: domain of linux.upstream@oneplus.com designates 40.107.129.117 as permitted sender) smtp.mailfrom=linux.upstream@oneplus.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=oneplus.com
Received: from KOR01-SL2-obe.outbound.protection.outlook.com (mail-eopbgr1290117.outbound.protection.outlook.com. [40.107.129.117])
        by mx.google.com with ESMTPS id l7si2107754plb.366.2019.02.11.06.01.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 11 Feb 2019 06:01:43 -0800 (PST)
Received-SPF: pass (google.com: domain of linux.upstream@oneplus.com designates 40.107.129.117 as permitted sender) client-ip=40.107.129.117;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oneplus.com header.s=selector1 header.b=L6ciJmOQ;
       spf=pass (google.com: domain of linux.upstream@oneplus.com designates 40.107.129.117 as permitted sender) smtp.mailfrom=linux.upstream@oneplus.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=oneplus.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oneplus.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=lo+Nw78TKhlhcoC/rXc93j6zWIDVsC/4u3zpOh+BXRI=;
 b=L6ciJmOQ9XBvlTNCuw9NlYFSaIVOw/Nb/f9xgs9jq519xEYoQ/bUlj5HZsXzfV5P89f9xBKcnDl18pFz7InUhQ1vryDB7pkRw6w5ZO2MRq3EoNcwCfWrmCUY9EuidDn4tzxWwlG9VW11EvhIQrNxpQLJZVsZbQgVdLIzbRCxTjo=
Received: from SL2PR04MB3436.apcprd04.prod.outlook.com (20.177.176.85) by
 SL2PR04MB3049.apcprd04.prod.outlook.com (20.177.176.143) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1601.22; Mon, 11 Feb 2019 14:01:40 +0000
Received: from SL2PR04MB3436.apcprd04.prod.outlook.com
 ([fe80::3437:6e26:53e1:ce17]) by SL2PR04MB3436.apcprd04.prod.outlook.com
 ([fe80::3437:6e26:53e1:ce17%3]) with mapi id 15.20.1601.023; Mon, 11 Feb 2019
 14:01:40 +0000
From: Linux Upstream <linux.upstream@oneplus.com>
To: Peter Zijlstra <peterz@infradead.org>, Chintan Pandya
	<chintan.pandya@oneplus.com>
CC: "hughd@google.com" <hughd@google.com>, "jack@suse.cz" <jack@suse.cz>,
	"mawilcox@microsoft.com" <mawilcox@microsoft.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [RFC 2/2] page-flags: Catch the double setter of page flags
Thread-Topic: [RFC 2/2] page-flags: Catch the double setter of page flags
Thread-Index: AQHUwgjZBmjQziiQR0KxJ364wLm0eqXanK8AgAAD2QA=
Date: Mon, 11 Feb 2019 14:01:39 +0000
Message-ID: <ce5a38bf-e842-f4cd-96bb-dbb350e545f5@oneplus.com>
References: <20190211125337.16099-1-chintan.pandya@oneplus.com>
 <20190211125337.16099-3-chintan.pandya@oneplus.com>
 <20190211134750.GB32511@hirez.programming.kicks-ass.net>
In-Reply-To: <20190211134750.GB32511@hirez.programming.kicks-ass.net>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: SG2PR02CA0043.apcprd02.prod.outlook.com
 (2603:1096:3:18::31) To SL2PR04MB3436.apcprd04.prod.outlook.com
 (2603:1096:100:39::21)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=linux.upstream@oneplus.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [14.143.173.238]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;SL2PR04MB3049;6:hWPahFs3VfOjHqTnr0K4fftOQCenbOBQDmVzCIk0x7eDJc1x8EArYg4uTIm9/n5j+Z+qLt1IbW0StkzI54FPqYibq+yf+nKWpyELbr81Q2iGTJ6cc05NMnNbWVlBxH3ZZajYWRA9EusJCxcPPCf/m3FC+x/L8d39UzuLiI4E0CzruGbAvB0gRgFR/xXTcPGLSw+zENY6sOcpNUXrJEIur8N9ic8eSfTITG+iRl+OHgdj9JJEngSlXCT8ZCmky+KmJNn3kgbDHaZyjxxJU1Glo0Rc6kEgCaqzUlKHNntUM+7rb5Wj8r7pEyrK2lmyuIDOaGcnGgE+AXRsWcFJecQiueAqyqawYAFtSdyDgS7QCQbTx1g3dT8IhVfwfCKE+oL4ObFogII8HU3DpQQy69E6eQgiCw4q4R4+3iXPKiEmWPbGIchopSa67MPba4DDA0TEhf1HxiPT9ZYwlKu2AQDZBw==;5:w8uRhxSlkswL0Tavz8gCiGQMSIS0Hw91uvZEYzLVyLSLYQgwyf4ZolTbblx3k4xbZPGyfifgn0tDd3p4ulFyQB56YUVYESZw6c0bzUkL/OQRTadZtCjok2uyAlYM0b6rzDm4sn54J84AS6IxxYBwQ6vR3REOTlJ5QMY/c0j/aY0q548oDjxovJAtEDx+TZ7mO0nSwA0+WVs5POlyp22E7A==;7:36TaLGdouPrTXhN96qLPobhUgfyymThRaAsiCg5GdVzJyQv9RGWa1zyFSSoJPVxzaKX7ZB/TZ3NhVNmzT44scFeZ6jrhaqhfe4YmGlmeTPo8ujRkA/zCmJdxjiJmXl0UdrnD6EDc2DCFTQPjgCav/A==
x-ms-office365-filtering-correlation-id: e90b0ca7-305c-4ab6-a87d-08d6902971d5
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(2017052603328)(7153060)(7193020);SRVR:SL2PR04MB3049;
x-ms-traffictypediagnostic: SL2PR04MB3049:
x-ld-processed: 0423909d-296c-463e-ab5c-e5853a518df8,ExtAddr
x-microsoft-antispam-prvs:
 <SL2PR04MB304933E3F58CFE933470023C9A640@SL2PR04MB3049.apcprd04.prod.outlook.com>
x-forefront-prvs: 0945B0CC72
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(346002)(366004)(376002)(136003)(39850400004)(396003)(199004)(189003)(316002)(476003)(6636002)(486006)(110136005)(2616005)(54906003)(6246003)(25786009)(478600001)(66066001)(81166006)(81156014)(11346002)(446003)(6512007)(55236004)(44832011)(53546011)(6506007)(386003)(229853002)(6436002)(102836004)(31686004)(6486002)(68736007)(36756003)(2906002)(14454004)(106356001)(186003)(26005)(105586002)(3846002)(256004)(6116002)(99286004)(86362001)(78486014)(14444005)(8676002)(8936002)(53936002)(31696002)(305945005)(71190400001)(4326008)(52116002)(71200400001)(76176011)(97736004)(7736002);DIR:OUT;SFP:1102;SCL:1;SRVR:SL2PR04MB3049;H:SL2PR04MB3436.apcprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: oneplus.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 vR2D4drELIZYXNug4tduUn/yzKWZC9taUu3pdnkivqPill0QCsUhXckS2q7NG+fVPZHWaG9Yq5yWdwl+9eMsNBqlXysfLlhcNHiE5gMCjS9jEFLKbdJH4YNTYkz1T1cvUkPWQ6+k8uA3U19nLMzYYNDdxe7TmB+Tn7wsnIJAMIfrKhpp8L2V3reGgctbf1V6Ixf/mRoPwU1WrI+Kco5XZLGXe8AqFCOoxT1JOwKGj8KZHVGxwvji7XJZnGYEJ4G3963PbhoHqqIL47fnuwB5ouNM3Us1FEk4AcREJm1iiDSWa04A3vSHkw4l6Fha50v1ILBw0po+IxwirbwgHFDXsb+uSS2oyvfkyNRiE6o6jdAijyOG/+3P5oHYxlOpqaOTL5hThH2Eyxa0DPJyHjW0xsOKvEBJOjOUTaq0wmZl/dk=
Content-Type: text/plain; charset="utf-8"
Content-ID: <470AC3FAA23B9541B424531A472106F0@apcprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: oneplus.com
X-MS-Exchange-CrossTenant-Network-Message-Id: e90b0ca7-305c-4ab6-a87d-08d6902971d5
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Feb 2019 14:01:38.4781
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: 0423909d-296c-463e-ab5c-e5853a518df8
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SL2PR04MB3049
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

DQoNCk9uIDExLzAyLzE5IDc6MTcgUE0sIFBldGVyIFppamxzdHJhIHdyb3RlOg0KPiBPbiBNb24s
IEZlYiAxMSwgMjAxOSBhdCAxMjo1Mzo1NVBNICswMDAwLCBDaGludGFuIFBhbmR5YSB3cm90ZToN
Cj4+IFNvbWUgb2YgdGhlIHBhZ2UgZmxhZ3MsIGxpa2UgUEdfbG9ja2VkIGlzIG5vdCBzdXBwb3Nl
ZCB0bw0KPj4gYmUgc2V0IHR3aWNlLiBDdXJyZW50bHksIHRoZXJlIGlzIG5vIHByb3RlY3Rpb24g
YXJvdW5kIHRoaXMNCj4+IGFuZCBtYW55IGNhbGxlcnMgZGlyZWN0bHkgdHJpZXMgdG8gc2V0IHRo
aXMgYml0LiBPdGhlcnMNCj4+IGZvbGxvdyB0cnlsb2NrX3BhZ2UoKSB3aGljaCBpcyBtdWNoIHNh
ZmVyIHZlcnNpb24gb2YgdGhlDQo+PiBzYW1lLiBCdXQsIGZvciBwZXJmb3JtYW5jZSBpc3N1ZXMs
IHdlIG1heSBub3Qgd2FudCB0bw0KPj4gaW1wbGVtZW50IHdhaXQtdW50aWwtc2V0LiBTbywgYXQg
bGVhc3QsIGZpbmQgb3V0IHdobyBpcw0KPj4gZG9pbmcgZG91YmxlIHNldHRpbmcgYW5kIGZpeCB0
aGVtLg0KPj4NCj4+IENoYW5nZS1JZDogSTEyOTVmY2I4NTI3Y2U0YjU0ZDVkMTFjMTEyODdmYzc1
MTYwMDZjZjANCj4+IFNpZ25lZC1vZmYtYnk6IENoaW50YW4gUGFuZHlhIDxjaGludGFuLnBhbmR5
YUBvbmVwbHVzLmNvbT4NCj4+IC0tLQ0KPj4gICBpbmNsdWRlL2xpbnV4L3BhZ2UtZmxhZ3MuaCB8
IDIgKy0NCj4+ICAgMSBmaWxlIGNoYW5nZWQsIDEgaW5zZXJ0aW9uKCspLCAxIGRlbGV0aW9uKC0p
DQo+Pg0KPj4gZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvcGFnZS1mbGFncy5oIGIvaW5jbHVk
ZS9saW51eC9wYWdlLWZsYWdzLmgNCj4+IGluZGV4IGE1NmE5YmQ0YmM2Yi4uZTMwNzc3NWMyYjRh
IDEwMDY0NA0KPj4gLS0tIGEvaW5jbHVkZS9saW51eC9wYWdlLWZsYWdzLmgNCj4+ICsrKyBiL2lu
Y2x1ZGUvbGludXgvcGFnZS1mbGFncy5oDQo+PiBAQCAtMjA4LDcgKzIwOCw3IEBAIHN0YXRpYyBf
X2Fsd2F5c19pbmxpbmUgaW50IFBhZ2UjI3VuYW1lKHN0cnVjdCBwYWdlICpwYWdlKQkJXA0KPj4g
ICANCj4+ICAgI2RlZmluZSBTRVRQQUdFRkxBRyh1bmFtZSwgbG5hbWUsIHBvbGljeSkJCQkJXA0K
Pj4gICBzdGF0aWMgX19hbHdheXNfaW5saW5lIHZvaWQgU2V0UGFnZSMjdW5hbWUoc3RydWN0IHBh
Z2UgKnBhZ2UpCQlcDQo+PiAtCXsgc2V0X2JpdChQR18jI2xuYW1lLCAmcG9saWN5KHBhZ2UsIDEp
LT5mbGFncyk7IH0NCj4+ICsJeyBXQVJOX09OKHRlc3RfYW5kX3NldF9iaXQoUEdfIyNsbmFtZSwg
JnBvbGljeShwYWdlLCAxKS0+ZmxhZ3MpKTsgfQ0KPiANCj4gWW91IGZvcmdvdCB0byBtYWtlIHRo
aXMgZGVwZW5kIG9uIENPTkZJR19ERUJVR19WTS4gQWxzbywgSSdtIG5vdA0KPiBjb252aW5jZWQg
dGhpcyBpcyBhbHdheXMgd3JvbmcsIGluZWZmaWNpZW50IHN1cmUsIGJ1dCBub3Qgd3JvbmcgaW4N
Cj4gZ2VuZXJhbC4NCg0KT2theS4gV2lsbCBwcm90ZWN0IHRoaXMgdW5kZXIgQ09ORklHX0RFQlVH
X1ZNLg0KDQo=

