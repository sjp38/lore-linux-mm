Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EF55C46460
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 17:41:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0983B208CA
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 17:41:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="dFmnXGFl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0983B208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9484D6B0005; Mon, 13 May 2019 13:41:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F9806B0007; Mon, 13 May 2019 13:41:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 79ABF6B0008; Mon, 13 May 2019 13:41:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 58A896B0005
	for <linux-mm@kvack.org>; Mon, 13 May 2019 13:41:43 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id d22so10439259ioh.14
        for <linux-mm@kvack.org>; Mon, 13 May 2019 10:41:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=QCdbNKQVEXtBCsICcQ6WoQ37OvkxU+sGCSZ5BQuMfes=;
        b=qpQ+trCNTkhEmzV0Ev8Jkx5gxIGzd9RbJaKTWhTaQAu0fIslgemwMgibu6plCSH6hK
         IhALVyibCzQi74WlwNdQDEIngpESSbvflVA9eLyy12ZNwuu8WBGTLJ8djInIrYfwPRK0
         VOkW8f4WPQ7JZwDZKeqj2D3kt4HgdXQppv8PuqYKyc9mnzIauzqwDZnF393jxUNG5tf8
         3Z4mUGbz0x8tU68XyHcz3/E6w0zHmKz0FRsyqCmZ+rfcDVyEFr/RfGyLanDoHyPOuoZp
         C7YuX9y5zFV8ARt+6uZB5CbY1kswlAKTAaVRrn7lmCO7YLvYDpdUPYQ7V6xtyrmelaP6
         1b0Q==
X-Gm-Message-State: APjAAAUDByTyv6K/pZTDFnJVJOtjyqxMnQt569H6ldtitoM+OowbR3hc
	oVLe/vfZB/oFNBI5s2ozwHRpuC2vPCYdTcBAKrosCE/o5jMvsxGZ6DSvFADinSuaiOjS5G2i+49
	0QquVGgx44hKRxBLQWidl2rmhzOjiwZU7WGDKHD+PvVos0VX33i/MtsH3rNFyv84MXg==
X-Received: by 2002:a02:1649:: with SMTP id a70mr20319998jaa.116.1557769303041;
        Mon, 13 May 2019 10:41:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyagVWffWEXcPoP2ZLtDhv2bf0Gm1Y6Nh7zAHGtPlAMAZxa3p+eOu+xRS7ADNtAT2+FUFb5
X-Received: by 2002:a02:1649:: with SMTP id a70mr20319946jaa.116.1557769302028;
        Mon, 13 May 2019 10:41:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557769302; cv=none;
        d=google.com; s=arc-20160816;
        b=pOfEmPVmWe3fe8ZGrXYIV8nbLCcs9SdWBjhOsPPLOx0W58AdKQSa64mWn4h5UHmV5l
         4D9rgbh/PBWW2m+01byG8YMVZ9vUvtTHNKwRMsLsnp+ku4rmBJpU9HAIHzsZzwfQby6w
         qjcx+tg/UAzdMITTcbNYicpoGuSOysN0IPDS9J24mDi141B0MOJOP1HO/MYGRFzOGgXd
         dF9fHAwQvjkTXHTnw+MgLUeTx3UvJz/qdyVinMLmN+45vc3qjZgSP6+SUSN6JWLSVkR2
         B/S5zxpK11Dp1M8OqekKwXB3AV8hWVHF7Rr+7nb3wAx5tHch2x8xEjvO79mQflPdHv/z
         ED/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=QCdbNKQVEXtBCsICcQ6WoQ37OvkxU+sGCSZ5BQuMfes=;
        b=QQGOj9tzkcfxwixm14AQojDE756+z7KkuXTNWC67htDZ0rnAt19J9Pry+IOYGzKSoM
         jXh3rqj3L0zZye4MPVhEw1rs3OWUK4Qh6Zfs8Aos2ohc0+t+IwtBpHUGx21MX78uvTIX
         CTNeR98m8sjzW3WHNZz2LESdIktQClz93gMHidMGVrBKql2PwdRQt1KD36zVmcHxcapv
         l/9lsdh1o3sI2MVROLriH2qnCQxj0rmgBGotIAMIF18sCx82gILhyYA4XYD00T2NLYkm
         tbVvwNHtkc5qdN8mFL5+j8PDPA65raT3piHMQ/8bVkSqOgCxvIrHG0IuKajtqBVGNyF6
         9zMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=dFmnXGFl;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.79.88 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-eopbgr790088.outbound.protection.outlook.com. [40.107.79.88])
        by mx.google.com with ESMTPS id 136si8087789jaa.31.2019.05.13.10.41.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 13 May 2019 10:41:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.79.88 as permitted sender) client-ip=40.107.79.88;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=dFmnXGFl;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.79.88 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=QCdbNKQVEXtBCsICcQ6WoQ37OvkxU+sGCSZ5BQuMfes=;
 b=dFmnXGFlevaBZ2dLXVCg5wcKuD0OpK1mmvimOLfvRLpQe0mBzcVeG6/X45ur+tARD0kGSffc0NJXLadvUtRrkqyQca01JC7JLuT6EC1/13QX+9y6uuyC88PQyFATLjU+5y6sPmyMECTJIW9bHJ6KIvHF2fUT3CRag1C8t0dqSaA=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB5109.namprd05.prod.outlook.com (20.177.231.15) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1900.5; Mon, 13 May 2019 17:41:38 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::b057:917a:f098:6098]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::b057:917a:f098:6098%7]) with mapi id 15.20.1900.010; Mon, 13 May 2019
 17:41:38 +0000
From: Nadav Amit <namit@vmware.com>
To: Peter Zijlstra <peterz@infradead.org>
CC: Yang Shi <yang.shi@linux.alibaba.com>, "jstancek@redhat.com"
	<jstancek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>, Linux-MM
	<linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Aneesh Kumar K .
 V" <aneesh.kumar@linux.vnet.ibm.com>, Nick Piggin <npiggin@gmail.com>,
	Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Will Deacon
	<will.deacon@arm.com>
Subject: Re: [PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
Thread-Topic: [PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
Thread-Index:
 AQHVBlNcdgyGQHvMg0ymTH6Y7O8srKZjDs8AgAANcoCAAAcZgIAABfcAgAAkYwCABXN1AIAACg2AgAACfYCAACNEAIAAaJyA
Date: Mon, 13 May 2019 17:41:38 +0000
Message-ID: <CEC6786F-C6DB-438D-AAA1-33DBEA8B8F0B@vmware.com>
References: <20190509083726.GA2209@brain-police>
 <20190509103813.GP2589@hirez.programming.kicks-ass.net>
 <F22533A7-016F-4506-809A-7E86BAF24D5A@vmware.com>
 <20190509182435.GA2623@hirez.programming.kicks-ass.net>
 <04668E51-FD87-4D53-A066-5A35ABC3A0D6@vmware.com>
 <20190509191120.GD2623@hirez.programming.kicks-ass.net>
 <7DA60772-3EE3-4882-B26F-2A900690DA15@vmware.com>
 <20190513083606.GL2623@hirez.programming.kicks-ass.net>
 <20190513091205.GO2650@hirez.programming.kicks-ass.net>
 <847D4C2F-BD26-4BE0-A5BA-3C690D11BF77@vmware.com>
 <20190513112712.GO2623@hirez.programming.kicks-ass.net>
In-Reply-To: <20190513112712.GO2623@hirez.programming.kicks-ass.net>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [50.204.119.4]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 94711ab4-18b1-4e7a-2b4a-08d6d7ca409d
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR05MB5109;
x-ms-traffictypediagnostic: BYAPR05MB5109:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs:
 <BYAPR05MB5109C0A12AB457ED96A6C044D00F0@BYAPR05MB5109.namprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 0036736630
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(366004)(376002)(39860400002)(346002)(396003)(136003)(189003)(199004)(81156014)(66556008)(64756008)(68736007)(73956011)(66946007)(66446008)(66066001)(66476007)(2906002)(6436002)(81166006)(36756003)(99286004)(53936002)(76116006)(6512007)(6306002)(102836004)(305945005)(53546011)(6506007)(6246003)(7736002)(486006)(11346002)(3846002)(6116002)(476003)(6486002)(4326008)(446003)(2616005)(5660300002)(25786009)(8936002)(229853002)(478600001)(76176011)(86362001)(966005)(14454004)(71200400001)(26005)(71190400001)(83716004)(7416002)(54906003)(82746002)(316002)(186003)(14444005)(33656002)(6916009)(256004)(8676002);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB5109;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 3Dlf80AsbmCfH5zyGa7hrpnk+u9p+CchJUgpFYTIbS5aCVABSFLimvILifMkc09z3EKRI8dUFlqa3c9JUZVLhQY9CWG2FHp03CvKkwrLFFaXMoRQVa9uWQhcyyzrMgtxocmTBMZgmC7sL8RoOzZTNZ3l6j9c9Wzjj0iUDHYWm5dAJvoE7tOAMznHVP25fnEMLIYIXIUnjS1ullnKrliZU6up7/e4+jo8Fy9tj/Rx0kwb847jc9IcDF2MjAl7yfcaoXk+9BxeeCB1WoVS85pMsIrO8Vpwf/T9SqB1M+2h4rwIlB0uixgBe0+uROMde2GeMdJQiCf4vucsdP9jzTYeqZQZK/2h5PXJok4AhQy3jEKzvYfNI4sLMPbheyCzn5YbfSuJqiHwIsaJTus9cipwUJ3Yyh+88+zNXmiMnQc6l4M=
Content-Type: text/plain; charset="utf-8"
Content-ID: <FEF401722DAF4E4FBB3E0E89AB5F04E4@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 94711ab4-18b1-4e7a-2b4a-08d6d7ca409d
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 May 2019 17:41:38.4103
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB5109
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

PiBPbiBNYXkgMTMsIDIwMTksIGF0IDQ6MjcgQU0sIFBldGVyIFppamxzdHJhIDxwZXRlcnpAaW5m
cmFkZWFkLm9yZz4gd3JvdGU6DQo+IA0KPiBPbiBNb24sIE1heSAxMywgMjAxOSBhdCAwOToyMTow
MUFNICswMDAwLCBOYWRhdiBBbWl0IHdyb3RlOg0KPj4+IE9uIE1heSAxMywgMjAxOSwgYXQgMjox
MiBBTSwgUGV0ZXIgWmlqbHN0cmEgPHBldGVyekBpbmZyYWRlYWQub3JnPiB3cm90ZToNCj4gDQo+
Pj4+IFRoZSBvdGhlciB0aGluZyBJIHdhcyB0aGlua2luZyBvZiBpcyB0cnlpbmcgdG8gZGV0ZWN0
IG92ZXJsYXAgdGhyb3VnaA0KPj4+PiB0aGUgcGFnZS10YWJsZXMgdGhlbXNlbHZlcywgYnV0IHdl
IGhhdmUgYSBkaXN0aW5jdCBsYWNrIG9mIHN0b3JhZ2UNCj4+Pj4gdGhlcmUuDQo+Pj4gDQo+Pj4g
V2UgbWlnaHQganVzdCB1c2Ugc29tZSBzdGF0ZSBpbiB0aGUgcG1kLCB0aGVyZSdzIHN0aWxsIDIg
X3B0X3BhZF9bMTJdIGluDQo+Pj4gc3RydWN0IHBhZ2UgdG8gJ3VzZScuIFNvIHdlIGNvdWxkIGNv
bWUgdXAgd2l0aCBzb21lIHRsYiBnZW5lcmF0aW9uDQo+Pj4gc2NoZW1lIHRoYXQgd291bGQgZGV0
ZWN0IGNvbmZsaWN0Lg0KPj4gDQo+PiBJdCBpcyByYXRoZXIgZWFzeSB0byBjb21lIHVwIHdpdGgg
YSBzY2hlbWUgKGFuZCBJIGRpZCBzaW1pbGFyIHRoaW5ncykgaWYgeW91DQo+PiBmbHVzaCB0aGUg
dGFibGUgd2hpbGUgeW91IGhvbGQgdGhlIHBhZ2UtdGFibGVzIGxvY2suIEJ1dCBpZiB5b3UgYmF0
Y2ggYWNyb3NzDQo+PiBwYWdlLXRhYmxlcyBpdCBiZWNvbWVzIGhhcmRlci4NCj4gDQo+IFllYWg7
IGZpbmRpbmcgdGhhdCBvdXQgbm93LiBJIGtlZXAgZmluZGluZyBob2xlcyA6Lw0KDQpZb3UgY2Fu
IHVzZSBVaGxpZ+KAmXMgZGlzc2VydGF0aW9uIGZvciBpbnNwaXJhdGlvbiAoU2VjdGlvbiA0LjQp
Lg0KDQpbMV0gaHR0cHM6Ly93d3cucmVzZWFyY2hnYXRlLm5ldC9wdWJsaWNhdGlvbi8zNjQ1MDQ4
Ml9TY2FsYWJpbGl0eV9vZl9taWNyb2tlcm5lbC1iYXNlZF9zeXN0ZW1zL2Rvd25sb2FkDQoNCj4g
DQo+PiBUaGlua2luZyBhYm91dCBpdCB3aGlsZSB0eXBpbmcsIHBlcmhhcHMgaXQgaXMgc2ltcGxl
ciB0aGFuIEkgdGhpbmsgLSBpZiB5b3UNCj4+IG5lZWQgdG8gZmx1c2ggcmFuZ2UgdGhhdCBydW5z
IGFjcm9zcyBtb3JlIHRoYW4gYSBzaW5nbGUgdGFibGUsIHlvdSBhcmUgdmVyeQ0KPj4gbGlrZWx5
IHRvIGZsdXNoIGEgcmFuZ2Ugb2YgbW9yZSB0aGFuIDMzIGVudHJpZXMsIHNvIGFueWhvdyB5b3Ug
YXJlIGxpa2VseSB0bw0KPj4gZG8gYSBmdWxsIFRMQiBmbHVzaC4NCj4gDQo+IFdlIGNhbid0IHJl
bHkgb24gdGhlIDMzLCB0aGF0IHg4NiBzcGVjaWZpYy4gT3RoZXIgYXJjaGl0ZWN0dXJlcyBjYW4g
aGF2ZQ0KPiBhbm90aGVyIChvciBubykgbGltaXQgb24gdGhhdC4NCg0KSSB3b25kZXIgd2hldGhl
ciB0aGVyZSBhcmUgYXJjaGl0ZWN0dXJlcyB0aGF0IGRvIG5vIGludmFsaWRhdGUgdGhlIFRMQiBl
bnRyeQ0KYnkgZW50cnksIGV4cGVyaWVuY2luZyB0aGVzZSBraW5kIG9mIG92ZXJoZWFkcy4NCg0K
Pj4gU28gcGVyaGFwcyBqdXN0IGF2b2lkaW5nIHRoZSBiYXRjaGluZyBpZiBvbmx5IGVudHJpZXMg
ZnJvbSBhIHNpbmdsZSB0YWJsZQ0KPj4gYXJlIGZsdXNoZWQgd291bGQgYmUgZW5vdWdoLg0KPiAN
Cj4gVGhhdCdzIG5lYXIgdG8gd2hhdCBXaWxsIHN1Z2dlc3RlZCBpbml0aWFsbHksIGp1c3QgZmx1
c2ggdGhlIGVudGlyZQ0KPiB0aGluZyB3aGVuIHRoZXJlJ3MgYSBjb25mbGljdC4NCg0KT25lIHF1
ZXN0aW9uIGlzIGhvdyB5b3UgZGVmaW5lIGEgY29uZmxpY3QuIElJVUMsIFdpbGwgc3VnZ2VzdHMg
c2FtZSBtbSBtYXJrcw0KYSBjb25mbGljdC4gSW4gYWRkaXRpb24sIEkgc3VnZ2VzdCB0aGF0IGlm
IHlvdSBvbmx5IHJlbW92ZSBhIHNpbmdsZSBlbnRyeQ0KKG9yIGZldyBvbmVzKSwgeW91IHdvdWxk
IGp1c3Qgbm90IGJhdGNoIGFuZCBkbyB0aGUgZmx1c2hpbmcgd2hpbGUgaG9sZGluZw0KdGhlIHBh
Z2UtdGFibGUgbG9jay4NCg0K

