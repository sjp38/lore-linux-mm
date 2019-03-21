Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CEEAC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 13:22:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1113121874
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 13:22:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="aOprZdwQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1113121874
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A1F5D6B0006; Thu, 21 Mar 2019 09:22:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A8656B0007; Thu, 21 Mar 2019 09:22:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8240B6B0008; Thu, 21 Mar 2019 09:22:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4214D6B0006
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 09:22:30 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 14so5484192pgf.22
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 06:22:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:accept-language:content-language
         :content-id:content-transfer-encoding:mime-version;
        bh=Ci1JgvY53IsFjqkrEJnhDAyV3m6wF2/lrA5nX6tnXEk=;
        b=ctOaJzeSArUaU+Vb0sFQ+pOY3EQl79UsukIfoC58aDsMfE+oOrWo2+NPc5njeKZpLs
         fgQxfdnuEzU0qkTxkgZb0F53C+lR4oMFPj7V8IYqkfwJ97SfbMkgV9uTgF08VHAryDgQ
         QBau3+uCaQLz62Kq+rRUT9rs2sWex3na6O+U3k43kVXqKyPu+eRqlHAzf/PMIJLLjx7E
         3e/OiElnSP1iqbHpf5Uo8j6glDkvP4lHMX3ciOJwB3Zd3ZBjnrYPWU9G8EvvHAs5ia31
         7hSAlGFPYIn4etaNt69ZDnOYRqZ9VSLOtB/+6RS1GZzi+iLBmqcCvRCoo2uqIqJZPvTw
         cW4A==
X-Gm-Message-State: APjAAAUUJLLS4UeThRlc4JEEvluaxAp9QaWftYeb4YfYDt5ngraxUsr0
	BW2839T2PJSzqewnMTbLrvbuhmZG82KGcD18x8011kcYCq2L8+X1UauH/12LxW9eEkmOZvFgJ12
	KMLzkFbxN9Yhg9Q5ENDUCZpcMYB7ifwaDTQxiph2PyQXf0PCzUxXpPYB39OIxTLNQ8Q==
X-Received: by 2002:a62:ed06:: with SMTP id u6mr3261727pfh.132.1553174549722;
        Thu, 21 Mar 2019 06:22:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyV4D5v4fEtrsEokkKEFzFLu6yPnglsIU7hzVQzTJAQNcBBh8vPFOes6Y14Jt673hwW0pgk
X-Received: by 2002:a62:ed06:: with SMTP id u6mr3261658pfh.132.1553174548701;
        Thu, 21 Mar 2019 06:22:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553174548; cv=none;
        d=google.com; s=arc-20160816;
        b=xUrKAcL515bZj2htawezgxW6n1l33sVAnMW/qJ5yAT44b+d6mUCv6ctLqr5aYG7r6e
         YKx79GpYN/GEZK5dtA5gif6aiLLPidOHTPu13gWtNXnPotMljBNVmrZdbryQ0OnIOvbT
         pw94aa6RFQNN0G3TL8z/ulo1b3VLLr193HDy0diXxJNSM56AMd6NacGF9nrpTtJvKlQs
         VxnguHje7dZt/oFGT0zwOa9gA/KukjMv0/ruKkDCMkxNKx1zW6kVJv307QwcM0Yq9X24
         E0eocxjgkbYgJRx6KwJh1Ded1WkMeKUQfnbn882PizIFOVUrmmH/3h+eFz2/Xel/HEiC
         5w+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :cc:to:from:dkim-signature;
        bh=Ci1JgvY53IsFjqkrEJnhDAyV3m6wF2/lrA5nX6tnXEk=;
        b=DarKWU1zWeRLI+qcfogIr9IYD19wCMSdnadRDcp7tDPRgskVyfWjEBhUZB5GdiWdJK
         tKsSE3d5FHatkht9XAPJqsZS9YC4GtAjhpjYqwUaCBVuAqduR3PeAyHNkZAksJGdP8me
         /V67Ugs8YNVBwSUTna0kSxGhCFY5hNulzI6Df7CJl6t7M4XG81gZpDSsk6JuwlbI7fU0
         62YFhguwvDdfJIVqRCLqYfkczkvlxipmJcz08g3ZGan92i+5nASrXw3X2+ZRv31jtOJ9
         iWT6wHaWn8OKFocl/hDL09fcOJkBzPau/XFo9y9/ZrvOjnibYfsYnJFqLErK/7IeG1ZT
         8nJg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=aOprZdwQ;
       spf=pass (google.com: domain of thellstrom@vmware.com designates 40.107.79.42 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-eopbgr790042.outbound.protection.outlook.com. [40.107.79.42])
        by mx.google.com with ESMTPS id a8si4013734pff.277.2019.03.21.06.22.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 21 Mar 2019 06:22:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmware.com designates 40.107.79.42 as permitted sender) client-ip=40.107.79.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=aOprZdwQ;
       spf=pass (google.com: domain of thellstrom@vmware.com designates 40.107.79.42 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Ci1JgvY53IsFjqkrEJnhDAyV3m6wF2/lrA5nX6tnXEk=;
 b=aOprZdwQWzbGgcPruJi1iGHv7b42+pyy/alhI7NUNTD0HAOT8AMjnLzTaERl95m8nH4votnS0+Fq12l0F5cqt24SK9pzXGuS9daRrsUkTl3daOo8/OejW4U1De4KCKI4TgvD4hX14jq53TgyIaq8O0D+7XKEi+PsL3PA4nqA5do=
Received: from MN2PR05MB6141.namprd05.prod.outlook.com (20.178.241.217) by
 MN2PR05MB6095.namprd05.prod.outlook.com (20.178.243.30) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1730.15; Thu, 21 Mar 2019 13:22:23 +0000
Received: from MN2PR05MB6141.namprd05.prod.outlook.com
 ([fe80::91e:292d:e304:78ad]) by MN2PR05MB6141.namprd05.prod.outlook.com
 ([fe80::91e:292d:e304:78ad%6]) with mapi id 15.20.1750.010; Thu, 21 Mar 2019
 13:22:23 +0000
From: Thomas Hellstrom <thellstrom@vmware.com>
To: "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	Linux-graphics-maintainer <Linux-graphics-maintainer@vmware.com>
CC: Thomas Hellstrom <thellstrom@vmware.com>, Andrew Morton
	<akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Will
 Deacon <will.deacon@arm.com>, Peter Zijlstra <peterz@infradead.org>, Rik van
 Riel <riel@surriel.com>, Minchan Kim <minchan@kernel.org>, Michal Hocko
	<mhocko@suse.com>, Huang Ying <ying.huang@intel.com>, Souptick Joarder
	<jrdr.linux@gmail.com>, =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: [RFC PATCH RESEND 0/3] mm modifications / helpers for emulated GPU
 coherent memory
Thread-Topic: [RFC PATCH RESEND 0/3] mm modifications / helpers for emulated
 GPU coherent memory
Thread-Index: AQHU3+ke+3ZNutXb50uqrjfFd5pvKw==
Date: Thu, 21 Mar 2019 13:22:22 +0000
Message-ID: <20190321132140.114878-1-thellstrom@vmware.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: BYAPR01CA0039.prod.exchangelabs.com (2603:10b6:a03:94::16)
 To MN2PR05MB6141.namprd05.prod.outlook.com (2603:10b6:208:c7::25)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=thellstrom@vmware.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-mailer: git-send-email 2.19.0.rc1
x-originating-ip: [208.91.2.1]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 9225d3f4-1a5d-476f-02a5-08d6ae004020
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:MN2PR05MB6095;
x-ms-traffictypediagnostic: MN2PR05MB6095:
x-ld-processed: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0,ExtAddr
x-microsoft-antispam-prvs:
 <MN2PR05MB6095929055BE4E78741F1505A1420@MN2PR05MB6095.namprd05.prod.outlook.com>
x-forefront-prvs: 0983EAD6B2
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(136003)(366004)(376002)(346002)(396003)(189003)(199004)(186003)(66574012)(86362001)(1076003)(71200400001)(68736007)(66066001)(71190400001)(26005)(476003)(2616005)(6506007)(386003)(97736004)(486006)(256004)(110136005)(25786009)(7416002)(54906003)(14444005)(102836004)(305945005)(316002)(6436002)(7736002)(2906002)(36756003)(52116002)(6486002)(14454004)(6636002)(3846002)(6116002)(105586002)(6512007)(106356001)(50226002)(5660300002)(53936002)(99286004)(8676002)(8936002)(4326008)(81156014)(2501003)(81166006)(478600001);DIR:OUT;SFP:1101;SCL:1;SRVR:MN2PR05MB6095;H:MN2PR05MB6141.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 b335V57y7dj2mCBh57Ya5Dkbaz2AVnlLnP9e12Mqc7N0pMH88E3YsrCT+0f4trHfA1V/trKLkz/jTUfB+nQSF88ZKgF6byuu53eoBSxw4q59iKayq8xgyQOfv7p8vm7XtggXavL6TAxdwgiM/A1GwwggvqijTCVZArDFQgm8muCCx2QaUf006q6eBgICFV43uG0JHveExk0Y8CwXLBeO7csKtsAZjeruRnmOQHsXwUydIhuTBgCKzBlJu5r99YgKLBgvsY8dQu5Hw5lJClYTtjxCu+lwQ8zej92Wgr5wKFrv8GQz/v9W6X4X+Yv7/S99dH03/hnAFUywaghCFJ/RvoN+t/Ddjl+QCvXzyiteeMh6m0O9BZYRINWyj9XICz36gigGpwj1sDbwp7aaVeiEkplPfyuyttAcB/tHp0AhwTQ=
Content-Type: text/plain; charset="utf-8"
Content-ID: <BEACE059AB8AB14C8758D22A12CAE733@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 9225d3f4-1a5d-476f-02a5-08d6ae004020
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 Mar 2019 13:22:23.3787
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR05MB6095
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Q2M6IEFuZHJldyBNb3J0b24gPGFrcG1AbGludXgtZm91bmRhdGlvbi5vcmc+DQpDYzogTWF0dGhl
dyBXaWxjb3ggPHdpbGx5QGluZnJhZGVhZC5vcmc+DQpDYzogV2lsbCBEZWFjb24gPHdpbGwuZGVh
Y29uQGFybS5jb20+DQpDYzogUGV0ZXIgWmlqbHN0cmEgPHBldGVyekBpbmZyYWRlYWQub3JnPg0K
Q2M6IFJpayB2YW4gUmllbCA8cmllbEBzdXJyaWVsLmNvbT4NCkNjOiBNaW5jaGFuIEtpbSA8bWlu
Y2hhbkBrZXJuZWwub3JnPg0KQ2M6IE1pY2hhbCBIb2NrbyA8bWhvY2tvQHN1c2UuY29tPg0KQ2M6
IEh1YW5nIFlpbmcgPHlpbmcuaHVhbmdAaW50ZWwuY29tPg0KQ2M6IFNvdXB0aWNrIEpvYXJkZXIg
PGpyZHIubGludXhAZ21haWwuY29tPg0KQ2M6ICJKw6lyw7RtZSBHbGlzc2UiIDxqZ2xpc3NlQHJl
ZGhhdC5jb20+DQpDYzogbGludXgtbW1Aa3ZhY2sub3JnDQpDYzogbGludXgta2VybmVsQHZnZXIu
a2VybmVsLm9yZw0KDQpSZXNlbmRpbmcgc2luY2UgbGFzdCBzZXJpZXMgd2FzIHNlbnQgdGhyb3Vn
aCBhIG1pcy1jb25maWd1cmVkIFNNVFAgc2VydmVyLg0KDQpIaSwNClRoaXMgaXMgYW4gZWFybHkg
UkZDIHRvIG1ha2Ugc3VyZSBJIGRvbid0IGdvIHRvbyBmYXIgaW4gdGhlIHdyb25nIGRpcmVjdGlv
bi4NCg0KTm9uLWNvaGVyZW50IEdQVXMgdGhhdCBjYW4ndCBkaXJlY3RseSBzZWUgY29udGVudHMg
aW4gQ1BVLXZpc2libGUgbWVtb3J5LA0KbGlrZSBWTVdhcmUncyBTVkdBIGRldmljZSwgcnVuIGlu
dG8gdHJvdWJsZSB3aGVuIHRyeWluZyB0byBpbXBsZW1lbnQNCmNvaGVyZW50IG1lbW9yeSByZXF1
aXJlbWVudHMgb2YgbW9kZXJuIGdyYXBoaWNzIEFQSXMuIEV4YW1wbGVzIGFyZQ0KVnVsa2FuIGFu
ZCBPcGVuR0wgNC40J3MgQVJCX2J1ZmZlcl9zdG9yYWdlLg0KDQpUbyByZW1lZHksIHdlIG5lZWQg
dG8gZW11bGF0ZSBjb2hlcmVudCBtZW1vcnkuIFR5cGljYWxseSB3aGVuIGl0J3MgZGV0ZWN0ZWQN
CnRoYXQgYSBidWZmZXIgb2JqZWN0IGlzIGFib3V0IHRvIGJlIGFjY2Vzc2VkIGJ5IHRoZSBHUFUs
IHdlIG5lZWQgdG8NCmdhdGhlciB0aGUgcmFuZ2VzIHRoYXQgaGF2ZSBiZWVuIGRpcnRpZWQgYnkg
dGhlIENQVSBzaW5jZSB0aGUgbGFzdCBvcGVyYXRpb24sDQphcHBseSBhbiBvcGVyYXRpb24gdG8g
bWFrZSB0aGUgY29udGVudCB2aXNpYmxlIHRvIHRoZSBHUFUgYW5kIGNsZWFyIHRoZQ0KdGhlIGRp
cnR5IHRyYWNraW5nLg0KDQpEZXBlbmRpbmcgb24gdGhlIHNpemUgb2YgdGhlIGJ1ZmZlciBvYmpl
Y3QgYW5kIHRoZSBhY2Nlc3MgcGF0dGVybiB0aGVyZSBhcmUNCnR3byBtYWpvciBwb3NzaWJpbGl0
aWVzOg0KDQoxKSBVc2UgcGFnZV9ta3dyaXRlKCkgYW5kIHBmbl9ta3dyaXRlKCkuIChHUFUgYnVm
ZmVyIG9iamVjdHMgYXJlIGJhY2tlZA0KZWl0aGVyIGJ5IFBDSSBkZXZpY2UgbWVtb3J5IG9yIGJ5
IGRyaXZlci1hbGxvY2VkIHBhZ2VzKS4NClRoZSBkaXJ0eS10cmFja2luZyBuZWVkcyB0byBiZSBy
ZXNldCBieSB3cml0ZS1wcm90ZWN0aW5nIHRoZSBhZmZlY3RlZCBwdGVzDQphbmQgZmx1c2ggdGxi
LiBUaGlzIGhhcyBhIGNvbXBsZXhpdHkgb2YgTyhudW1fZGlydHlfcGFnZXMpLCBidXQgdGhlDQp3
cml0ZSBwYWdlLWZhdWx0IGlzIG9mIGNvdXJzZSBjb3N0bHkuDQoNCjIpIFVzZSBoYXJkd2FyZSBk
aXJ0eS1mbGFncyBpbiB0aGUgcHRlcy4gVGhlIGRpcnR5LXRyYWNraW5nIG5lZWRzIHRvIGJlIHJl
c2V0DQpieSBjbGVhcmluZyB0aGUgZGlydHkgYml0cyBhbmQgZmx1c2ggdGxiLiBUaGlzIGhhcyBh
IGNvbXBsZXhpdHkgb2YNCk8obnVtX2J1ZmZlcl9vYmplY3RfcGFnZXMpIGFuZCBkaXJ0eSBiaXRz
IG5lZWQgdG8gYmUgc2Nhbm5lZCBpbiBmdWxsIGJlZm9yZQ0KZWFjaCBncHUtYWNjZXNzLg0KDQpT
byBpbiBwcmFjdGljZSB0aGUgdHdvIG1ldGhvZHMgbmVlZCB0byBiZSBpbnRlcmxlYXZlZCBmb3Ig
YmVzdCBwZXJmb3JtYW5jZS4NCg0KU28gdG8gZmFjaWxpdGF0ZSB0aGlzLCBJIHByb3Bvc2UgdHdv
IG5ldyBoZWxwZXJzLCBhcHBseV9hc193cnByb3RlY3QoKSBhbmQNCmFwcGx5X2FzX2NsZWFuKCkg
KCJhcyIgc3RhbmRzIGZvciBhZGRyZXNzLXNwYWNlKSBib3RoIGluc3BpcmVkIGJ5DQp1bm1hcF9t
YXBwaW5nX3JhbmdlKCkuIFVzZXJzIG9mIHRoZXNlIGhlbHBlcnMgYXJlIGluIHRoZSBtYWtpbmcs
IGJ1dCBuZWVkcw0Kc29tZSBjbGVhbmluZy11cC4NCg0KVGhlcmUncyBhbHNvIGEgY2hhbmdlIHRv
IHhfbWt3cml0ZSgpIHRvIGFsbG93IGRyb3BwaW5nIHRoZSBtbWFwX3NlbSB3aGlsZQ0Kd2FpdGlu
Zy4NCg0KQW55IGNvbW1lbnRzIG9yIHN1Z2dlc3Rpb25zIGFwcHJlY2lhdGVkLg0KDQpUaGFua3Ms
DQpUaG9tYXMNCg0KDQoNCg==

