Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D9DBC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 19:51:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2CFEE218D4
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 19:51:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="b59OvXVR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2CFEE218D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C31BB6B0003; Thu, 21 Mar 2019 15:51:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C09116B0006; Thu, 21 Mar 2019 15:51:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD02C6B0007; Thu, 21 Mar 2019 15:51:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 79B336B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 15:51:21 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id s133so3053220oif.19
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 12:51:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=BGSiu13dUp7oajgpUiOR4JIxbz3D4JX/iGNMIe/jGhA=;
        b=bsVbF/KKyuXAn6dV1w8MozL8rWpVl67QoHuoU1GemndNSw4IsDawsF+ZnyBfCxRSMM
         eZ2lvsQWzOfQ41dAL3oEE81097QGPumb84xpM9RkAvPje6miyTWvcZaOjXoceEXHI8fz
         QFZ0Jt3QDKwvs5gob2+xTdLRkuHEp5ZOA49eNqD3Z+8eZmS7i+UCgq14Hr3Api7kPEz4
         hOj32qJseTJvCMxxyDM9MpxKKjfVnNgw8tJLVX8UvQwBs8qDim8ixH1FXT4L4Qzfc6+C
         Ijrjo4cl+v4HHu+gN5f0zwg5QmbHnaRr++HtYRXAffSYRciGdgt4omi/1jHWV+WqsWvW
         VfMA==
X-Gm-Message-State: APjAAAXhAs3sSBULQA7Rt0h4WaOs7luYZ/fxx20Dv5GoGKOI8cBXcSy1
	16Luk6rJydbLTh3/oFLAG4WBNkAwusVvEUHPfTZ3y9R2PX/92qjC8QAaOSGMQgGfag2q9f54iBc
	jWBJBhabJfugDrAAZDeW4r1yPHXTjCaW2pOSKao2XwXjuJkjoIfuDFiNNYYjcVhdygA==
X-Received: by 2002:aca:b408:: with SMTP id d8mr737552oif.15.1553197880958;
        Thu, 21 Mar 2019 12:51:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwbSNbEZa3wdtgaGsOg0XVZNbH36YL/bLOQXZnlMvvFA0B1DlRkGaOoxm+zNUY3axTce7hp
X-Received: by 2002:aca:b408:: with SMTP id d8mr737519oif.15.1553197880131;
        Thu, 21 Mar 2019 12:51:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553197880; cv=none;
        d=google.com; s=arc-20160816;
        b=GSbuw0tj3nXuYnvM7tU1RSxwrUkPo3C+fo2kL+XxNL90vZhuA8P+elAeIde4AXNHqJ
         7+WYJU64RQIoRet1jPJ3yYMYQQ2HBaECi9FeHCB2DcVQim7b+01gPbAOQgfaOz7bEm7j
         HoeOE8XPjnv5mfR7XrENRV4WCJFFUkHQ7/esmBDjF1uQGGuSlxjN8T2cgvYi5uHXnqJC
         jKUPPtmSOioLiuswk3fmAG/FYmLijMHnhzzOTOvEYPPYCUhXTOACEgzGHdCtJm92a0oX
         jjhzoY/r7s1Ky0HIiAwIHa0bbhh6hBV1FgqxRzbyJirV+k5pPmmzdctQm6Y8Z6WQTMUz
         I4Pw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=BGSiu13dUp7oajgpUiOR4JIxbz3D4JX/iGNMIe/jGhA=;
        b=uGCvG+6tNXNy8CCkshzEi+Q9tDkI3h6dbDO0n7flpkE7L6kml7fOiK4SPIgwbgFG4J
         m+QfC3OoUBaTyZkmZAV9yduMP1RjYTF1FoKoFhDNuy2BZ4w2ZeD+cFt1hvWBduf+Cbbn
         qip1LP+CryYPEHgVgqxtMFaEd0kpEo9ldkyJrcoY6/9hhP9dvlM5W09YJEEPEus3OLeC
         4QXptBPO/z77CI7wCT9l14HXdT3EBACaxF2ZOIm51kRSUl70nHx3yIsJxMtyLNuR6qPr
         UMkee9yVcQ+Y4GkkmtcW83vvfeHnlxUugjrqGQLNcY9XMhV3bkulJeTKqbqVcJ6nkTUF
         preA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=b59OvXVR;
       spf=pass (google.com: domain of thellstrom@vmware.com designates 40.107.81.73 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-eopbgr810073.outbound.protection.outlook.com. [40.107.81.73])
        by mx.google.com with ESMTPS id p188si2286479oib.141.2019.03.21.12.51.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 21 Mar 2019 12:51:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmware.com designates 40.107.81.73 as permitted sender) client-ip=40.107.81.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=b59OvXVR;
       spf=pass (google.com: domain of thellstrom@vmware.com designates 40.107.81.73 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=BGSiu13dUp7oajgpUiOR4JIxbz3D4JX/iGNMIe/jGhA=;
 b=b59OvXVRtasUjSqq/cEckVy+hwd+K/cwR++vPFmO3f5UqvjlHEVmCOzZdxEJ4r0UnMLCxcOGTnrnq2+c9kIy/Fdej33pAlXI/2h35f0cyWV6jlBNkdjAqVLM00Bj93KdDryslFiOCD63lU6X5FZN7VfGCV8G1SWb5f4EtNfnZv0=
Received: from MN2PR05MB6141.namprd05.prod.outlook.com (20.178.241.217) by
 MN2PR05MB6143.namprd05.prod.outlook.com (20.178.244.96) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1750.10; Thu, 21 Mar 2019 19:51:17 +0000
Received: from MN2PR05MB6141.namprd05.prod.outlook.com
 ([fe80::91e:292d:e304:78ad]) by MN2PR05MB6141.namprd05.prod.outlook.com
 ([fe80::91e:292d:e304:78ad%6]) with mapi id 15.20.1750.010; Thu, 21 Mar 2019
 19:51:17 +0000
From: Thomas Hellstrom <thellstrom@vmware.com>
To: "jglisse@redhat.com" <jglisse@redhat.com>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"peterz@infradead.org" <peterz@infradead.org>, "willy@infradead.org"
	<willy@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"jrdr.linux@gmail.com" <jrdr.linux@gmail.com>, "akpm@linux-foundation.org"
	<akpm@linux-foundation.org>, "minchan@kernel.org" <minchan@kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"will.deacon@arm.com" <will.deacon@arm.com>, Linux-graphics-maintainer
	<Linux-graphics-maintainer@vmware.com>, "mhocko@suse.com" <mhocko@suse.com>,
	"ying.huang@intel.com" <ying.huang@intel.com>, "riel@surriel.com"
	<riel@surriel.com>
Subject: Re: [RFC PATCH RESEND 0/3] mm modifications / helpers for emulated
 GPU coherent memory
Thread-Topic: [RFC PATCH RESEND 0/3] mm modifications / helpers for emulated
 GPU coherent memory
Thread-Index: AQHU3+ke+3ZNutXb50uqrjfFd5pvK6YWGQgAgABmCIA=
Date: Thu, 21 Mar 2019 19:51:16 +0000
Message-ID: <428b30355f4df864235428eaa24e207b8ba6c1ea.camel@vmware.com>
References: <20190321132140.114878-1-thellstrom@vmware.com>
	 <20190321134603.GB2904@redhat.com>
In-Reply-To: <20190321134603.GB2904@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [155.4.205.56]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 8a8754cd-8b66-40a1-b175-08d6ae369500
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:MN2PR05MB6143;
x-ms-traffictypediagnostic: MN2PR05MB6143:
x-microsoft-antispam-prvs:
 <MN2PR05MB6143837BC153C406DBF7CF46A1420@MN2PR05MB6143.namprd05.prod.outlook.com>
x-forefront-prvs: 0983EAD6B2
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(366004)(136003)(346002)(376002)(396003)(199004)(189003)(2906002)(6916009)(6116002)(3846002)(53936002)(305945005)(71200400001)(71190400001)(68736007)(7736002)(486006)(6436002)(6486002)(6246003)(229853002)(446003)(11346002)(476003)(105586002)(4326008)(2616005)(6512007)(5660300002)(76176011)(5640700003)(6506007)(256004)(6346003)(14444005)(102836004)(97736004)(26005)(186003)(66066001)(316002)(2501003)(54906003)(118296001)(99286004)(81166006)(66574012)(81156014)(1730700003)(2351001)(8936002)(106356001)(8676002)(7416002)(86362001)(36756003)(25786009)(478600001)(14454004);DIR:OUT;SFP:1101;SCL:1;SRVR:MN2PR05MB6143;H:MN2PR05MB6141.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=thellstrom@vmware.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 mZHUJ4vzaZMnBRJoCDjkg4MkWrFgME6qcSK0rfsdsQ07gX99Zi9sngaLZsOuWms3WEVRR99xKUlpFK6aFeXP04BEGCu8n+omni7G101w12Q5eLpVf6w8XQe7oVGjM1etJd8RvVIwuHEs2AVcwRac5bagp3oL4HJFNLZrcN/iHIdn5P3yABmnASU/Hg8NqZEIxwQi7w0O9xDdfIDo1sI2cJtO/g9liRKOq0pKDn9ZGhtclwlZbowOYOtfcE1ZuJEPstPrgGQlgdqMWRhlsKkHqeZ21qOuYDYaBypB74FI8zKgPx3yfM6rgMsIX8Stglz4XOWh0hktv+aJmiHrlGzicMc44veuiFX744FuVWZscBfFuTkCcY7VvKG0IKfm+lc4pSU1pb9MSJgOAmfLqmAcGXG+uZ1SpgEh93EJhpdoDtg=
Content-Type: text/plain; charset="utf-8"
Content-ID: <C07325463B6F4E4E80E1572C9EDADB2A@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 8a8754cd-8b66-40a1-b175-08d6ae369500
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 Mar 2019 19:51:17.0391
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR05MB6143
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGksIErDqXLDtG1lLA0KDQpUaGFua3MgZm9yIGNvbW1lbnRpbmcuIEkgaGF2ZSBhIGNvdXBsZSBv
ZiBxdWVzdGlvbnMgLyBjbGFyaWZpY2F0aW9ucw0KYmVsb3cuDQoNCk9uIFRodSwgMjAxOS0wMy0y
MSBhdCAwOTo0NiAtMDQwMCwgSmVyb21lIEdsaXNzZSB3cm90ZToNCj4gT24gVGh1LCBNYXIgMjEs
IDIwMTkgYXQgMDE6MjI6MjJQTSArMDAwMCwgVGhvbWFzIEhlbGxzdHJvbSB3cm90ZToNCj4gPiBS
ZXNlbmRpbmcgc2luY2UgbGFzdCBzZXJpZXMgd2FzIHNlbnQgdGhyb3VnaCBhIG1pcy1jb25maWd1
cmVkIFNNVFANCj4gPiBzZXJ2ZXIuDQo+ID4gDQo+ID4gSGksDQo+ID4gVGhpcyBpcyBhbiBlYXJs
eSBSRkMgdG8gbWFrZSBzdXJlIEkgZG9uJ3QgZ28gdG9vIGZhciBpbiB0aGUgd3JvbmcNCj4gPiBk
aXJlY3Rpb24uDQo+ID4gDQo+ID4gTm9uLWNvaGVyZW50IEdQVXMgdGhhdCBjYW4ndCBkaXJlY3Rs
eSBzZWUgY29udGVudHMgaW4gQ1BVLXZpc2libGUNCj4gPiBtZW1vcnksDQo+ID4gbGlrZSBWTVdh
cmUncyBTVkdBIGRldmljZSwgcnVuIGludG8gdHJvdWJsZSB3aGVuIHRyeWluZyB0bw0KPiA+IGlt
cGxlbWVudA0KPiA+IGNvaGVyZW50IG1lbW9yeSByZXF1aXJlbWVudHMgb2YgbW9kZXJuIGdyYXBo
aWNzIEFQSXMuIEV4YW1wbGVzIGFyZQ0KPiA+IFZ1bGthbiBhbmQgT3BlbkdMIDQuNCdzIEFSQl9i
dWZmZXJfc3RvcmFnZS4NCj4gPiANCj4gPiBUbyByZW1lZHksIHdlIG5lZWQgdG8gZW11bGF0ZSBj
b2hlcmVudCBtZW1vcnkuIFR5cGljYWxseSB3aGVuIGl0J3MNCj4gPiBkZXRlY3RlZA0KPiA+IHRo
YXQgYSBidWZmZXIgb2JqZWN0IGlzIGFib3V0IHRvIGJlIGFjY2Vzc2VkIGJ5IHRoZSBHUFUsIHdl
IG5lZWQgdG8NCj4gPiBnYXRoZXIgdGhlIHJhbmdlcyB0aGF0IGhhdmUgYmVlbiBkaXJ0aWVkIGJ5
IHRoZSBDUFUgc2luY2UgdGhlIGxhc3QNCj4gPiBvcGVyYXRpb24sDQo+ID4gYXBwbHkgYW4gb3Bl
cmF0aW9uIHRvIG1ha2UgdGhlIGNvbnRlbnQgdmlzaWJsZSB0byB0aGUgR1BVIGFuZCBjbGVhcg0K
PiA+IHRoZQ0KPiA+IHRoZSBkaXJ0eSB0cmFja2luZy4NCj4gPiANCj4gPiBEZXBlbmRpbmcgb24g
dGhlIHNpemUgb2YgdGhlIGJ1ZmZlciBvYmplY3QgYW5kIHRoZSBhY2Nlc3MgcGF0dGVybg0KPiA+
IHRoZXJlIGFyZQ0KPiA+IHR3byBtYWpvciBwb3NzaWJpbGl0aWVzOg0KPiA+IA0KPiA+IDEpIFVz
ZSBwYWdlX21rd3JpdGUoKSBhbmQgcGZuX21rd3JpdGUoKS4gKEdQVSBidWZmZXIgb2JqZWN0cyBh
cmUNCj4gPiBiYWNrZWQNCj4gPiBlaXRoZXIgYnkgUENJIGRldmljZSBtZW1vcnkgb3IgYnkgZHJp
dmVyLWFsbG9jZWQgcGFnZXMpLg0KPiA+IFRoZSBkaXJ0eS10cmFja2luZyBuZWVkcyB0byBiZSBy
ZXNldCBieSB3cml0ZS1wcm90ZWN0aW5nIHRoZQ0KPiA+IGFmZmVjdGVkIHB0ZXMNCj4gPiBhbmQg
Zmx1c2ggdGxiLiBUaGlzIGhhcyBhIGNvbXBsZXhpdHkgb2YgTyhudW1fZGlydHlfcGFnZXMpLCBi
dXQgdGhlDQo+ID4gd3JpdGUgcGFnZS1mYXVsdCBpcyBvZiBjb3Vyc2UgY29zdGx5Lg0KPiA+IA0K
PiA+IDIpIFVzZSBoYXJkd2FyZSBkaXJ0eS1mbGFncyBpbiB0aGUgcHRlcy4gVGhlIGRpcnR5LXRy
YWNraW5nIG5lZWRzDQo+ID4gdG8gYmUgcmVzZXQNCj4gPiBieSBjbGVhcmluZyB0aGUgZGlydHkg
Yml0cyBhbmQgZmx1c2ggdGxiLiBUaGlzIGhhcyBhIGNvbXBsZXhpdHkgb2YNCj4gPiBPKG51bV9i
dWZmZXJfb2JqZWN0X3BhZ2VzKSBhbmQgZGlydHkgYml0cyBuZWVkIHRvIGJlIHNjYW5uZWQgaW4N
Cj4gPiBmdWxsIGJlZm9yZQ0KPiA+IGVhY2ggZ3B1LWFjY2Vzcy4NCj4gPiANCj4gPiBTbyBpbiBw
cmFjdGljZSB0aGUgdHdvIG1ldGhvZHMgbmVlZCB0byBiZSBpbnRlcmxlYXZlZCBmb3IgYmVzdA0K
PiA+IHBlcmZvcm1hbmNlLg0KPiA+IA0KPiA+IFNvIHRvIGZhY2lsaXRhdGUgdGhpcywgSSBwcm9w
b3NlIHR3byBuZXcgaGVscGVycywNCj4gPiBhcHBseV9hc193cnByb3RlY3QoKSBhbmQNCj4gPiBh
cHBseV9hc19jbGVhbigpICgiYXMiIHN0YW5kcyBmb3IgYWRkcmVzcy1zcGFjZSkgYm90aCBpbnNw
aXJlZCBieQ0KPiA+IHVubWFwX21hcHBpbmdfcmFuZ2UoKS4gVXNlcnMgb2YgdGhlc2UgaGVscGVy
cyBhcmUgaW4gdGhlIG1ha2luZywNCj4gPiBidXQgbmVlZHMNCj4gPiBzb21lIGNsZWFuaW5nLXVw
Lg0KPiANCj4gVG8gYmUgY2xlYXIgdGhpcyBzaG91bGQgX29ubHkgYmUgdXNlXyBmb3IgbW1hcCBv
ZiBkZXZpY2UgZmlsZSA/IElmIHNvDQo+IHRoZSBBUEkgc2hvdWxkIHRyeSB0byBlbmZvcmNlIHRo
YXQgYXMgbXVjaCBhcyBwb3NzaWJsZSBmb3IgaW5zdGFuY2UNCj4gYnkNCj4gbWFuZGF0aW5nIHRo
ZSBmaWxlIGFzIGFyZ3VtZW50IHNvIHRoYXQgdGhlIGZ1bmN0aW9uIGNhbiBjaGVjayBpdCBpcw0K
PiBvbmx5IHVzZSBpbiB0aGF0IGNhc2UuIEFsc28gYmlnIHNjYXJ5IGNvbW1lbnQgdG8gbWFrZSBz
dXJlIG5vIG9uZQ0KPiBqdXN0DQo+IHN0YXJ0IHVzaW5nIHRob3NlIG91dHNpZGUgdGhpcyB2ZXJ5
IGxpbWl0ZWQgZnJhbWUuDQoNCkZpbmUgd2l0aCBtZS4gUGVyaGFwcyB3ZSBjb3VsZCBCVUcoKSAv
IFdBUk4oKSBvbiBjZXJ0YWluIFZNQSBmbGFncyANCmluc3RlYWQgb2YgbWFuZGF0aW5nIHRoZSBm
aWxlIGFzIGFyZ3VtZW50LiBUaGF0IGNhbiBtYWtlIHN1cmUgd2UNCmRvbid0IGFjY2lkZW50bHkg
aGl0IHBhZ2VzIHdlIHNob3VsZG4ndCBoaXQuDQoNCj4gDQo+ID4gVGhlcmUncyBhbHNvIGEgY2hh
bmdlIHRvIHhfbWt3cml0ZSgpIHRvIGFsbG93IGRyb3BwaW5nIHRoZSBtbWFwX3NlbQ0KPiA+IHdo
aWxlDQo+ID4gd2FpdGluZy4NCj4gDQo+IFRoaXMgd2lsbCBtb3N0IGxpa2VseSBjb25mbGljdCB3
aXRoIHVzZXJmYXVsdGZkIHdyaXRlIHByb3RlY3Rpb24uIA0KDQpBcmUgeW91IHJlZmVycmluZyB0
byB0aGUgeF9ta3dyaXRlKCkgdXNhZ2UgaXRzZWxmIG9yIHRoZSBtbWFwX3NlbQ0KZHJvcHBpbmcg
ZmFjaWxpdGF0aW9uPw0KDQo+IE1heWJlDQo+IGJ1aWxkaW5nIHlvdXIgdGhpbmcgb24gdG9wIG9m
IHRoYXQgd291bGQgYmUgYmV0dGVyLg0KPiANCj4gDQouLi4NCj4gDQo+IEkgd2lsbCB0YWtlIGEg
Y3Vyc29yeSBsb29rIGF0IHRoZSBwYXRjaGVzLg0KPiANCg0KU29tZSBtb3JlIHF1ZXN0aW9ucyAv
IGNsYXJpZmljYXRpb25zIG9uIHRob3NlIGFzIHdlbGwuDQoNCg0KPiBDaGVlcnMsDQo+IErDqXLD
tG1lDQo=

