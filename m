Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77799C10F09
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 17:43:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30A2A205F4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 17:43:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30A2A205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA3468E0003; Fri,  8 Mar 2019 12:43:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A54BC8E0002; Fri,  8 Mar 2019 12:43:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 91BE48E0003; Fri,  8 Mar 2019 12:43:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 440128E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 12:43:32 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id z1so22817253pfz.8
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 09:43:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=bvK1UBDUReH3s1vpqtcb5wme+q88hTP4LVoyanMoobE=;
        b=KSeQaQz1GKBpNm3utugt/DbfI3va+wrujjTNrUeSHbjU69iuGxCHp47Zy5hbpqNGvW
         ZTeqzMvRDloU3s1M1U/ifWC7uobPelMWkkUCrX9T4Ss8PJGwWsBVDjqjlJYF+EPAxYW6
         lrzr4XZyp/fCG0kf4gK7mGbnF0WIxfrUlEVVoRQSM2+Q/8IuSYwdeuy99E6hIqrGq35X
         Bh9oQ7gsnYmk7G4ntZjDaSVeLiPQT2+IesN77J9AbU5m+l1GW2hQ23/VuMH7+0/FQ5gG
         z1MfL9c0fumqnoiMmKdwfR3siELOWHx2eBr2SXclsag4AmRlxIs0bpvw0gV4itWuLkn6
         2QcA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX5h1P2pqKMWal8t2AkIyjWqvEfstxcYlzB+etN1BiHiO2pUGTo
	WFHNh32rnTLfFz9ibGhAps7g4dSj1xMy/Y8weqDHn1KP+I0S/or6mJn34Avfa4xqzL2DZBPf1sx
	MSjRp2IH2atY3qtgysoOZJeLTQ3M0ae2ej7f33rZ0gXd1ZSa4NGrYWMj4N/7CFQQXsw==
X-Received: by 2002:a62:3001:: with SMTP id w1mr19725800pfw.59.1552067011910;
        Fri, 08 Mar 2019 09:43:31 -0800 (PST)
X-Google-Smtp-Source: APXvYqy/AWFuB9tEG6OmXV77puyPT0ExIWo66D31/0F14mB/LuFLVUwrhmPRHexCklHvNp/bzd+P
X-Received: by 2002:a62:3001:: with SMTP id w1mr19725729pfw.59.1552067010814;
        Fri, 08 Mar 2019 09:43:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552067010; cv=none;
        d=google.com; s=arc-20160816;
        b=cvJYsINLtILN6wKpAavK2BbkDk+8m7d9wVfvuZ8iqgoDVEs8NQsak3zZKMbMK16k5Q
         RWNqsdRGMIz0dvygptwk5W/J9RIvBrLD1aj45MJj5nhepqR9Sw65i5sB5wmRaY/rIeTJ
         GYrMwsEJtu7AlQwYrk/PPPr1UUGuopHP2VxGkThpqtIGKCquS123fOPwYAGbnSX8i4jD
         HcDszpDowmsLR0r0bAUU3sSIsloDfl2dCiCMI9e6mNtvyXgoyidG/3sbMzFlXs35wuHu
         SU08qZbkapCd9b4ldlFuYHelz2fawlU+HfTG9+9zBWjrAszYq1GsSKt6I9faUMgvadpV
         SrMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=bvK1UBDUReH3s1vpqtcb5wme+q88hTP4LVoyanMoobE=;
        b=AaLydVl7CV0txiiDEmAHn8IiEMglz2jV27pm70o4KeYDkYZgaPc0dD6zu7iIWlxa4q
         ErUU1ZGORWl+FCpQ59TfQwK8TmRdnSSakt7xJ49XAlEcGYaGU1FQhHGb23RBx07qIa8o
         FMQxo7XsCPTL8bUA1aCn3kIrWUlcJUwKqB+JcVevtEVWrejHhkKGY4qe4CRD9rHj97S4
         DKiNap7u8HK4MMSenvaxk8N3PH+zeJOtX18a579kmBNnTgSmUdHazdMLck3zI4vvWsN7
         Ewy0MGC2kPvQ7AfCrLBuop6solCHNpVyZhJzeoAXLQL4M4/tXJL+zNIBws0sekS0Fywg
         vkGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id b27si6703976pgb.366.2019.03.08.09.43.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 09:43:30 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 Mar 2019 09:43:26 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,456,1544515200"; 
   d="scan'208";a="153300716"
Received: from fmsmsx103.amr.corp.intel.com ([10.18.124.201])
  by fmsmga001.fm.intel.com with ESMTP; 08 Mar 2019 09:43:26 -0800
Received: from fmsmsx155.amr.corp.intel.com (10.18.116.71) by
 FMSMSX103.amr.corp.intel.com (10.18.124.201) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Fri, 8 Mar 2019 09:43:25 -0800
Received: from crsmsx151.amr.corp.intel.com (172.18.7.86) by
 FMSMSX155.amr.corp.intel.com (10.18.116.71) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Fri, 8 Mar 2019 09:43:25 -0800
Received: from crsmsx101.amr.corp.intel.com ([169.254.1.61]) by
 CRSMSX151.amr.corp.intel.com ([169.254.3.216]) with mapi id 14.03.0415.000;
 Fri, 8 Mar 2019 11:43:23 -0600
From: "Weiny, Ira" <ira.weiny@intel.com>
To: John Hubbard <jhubbard@nvidia.com>, Christopher Lameter <cl@linux.com>,
	"john.hubbard@gmail.com" <john.hubbard@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, Al Viro <viro@zeniv.linux.org.uk>, Christian Benvenuti
	<benve@cisco.com>, Christoph Hellwig <hch@infradead.org>, "Williams, Dan J"
	<dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>,
	"Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford
	<dledford@redhat.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe
	<jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, Matthew Wilcox
	<willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Mike Rapoport
	<rppt@linux.ibm.com>, "Marciniszyn, Mike" <mike.marciniszyn@intel.com>,
	"Ralph Campbell" <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>, LKML
	<linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>
Subject: RE: [PATCH v3 1/1] mm: introduce put_user_page*(), placeholder
 versions
Thread-Topic: [PATCH v3 1/1] mm: introduce put_user_page*(), placeholder
 versions
Thread-Index: AQHU1HgH2MR3SD1MNEGIIx6i7GFct6YBcVgAgAAEpACAAIuG4A==
Date: Fri, 8 Mar 2019 17:43:23 +0000
Message-ID: <2807E5FD2F6FDA4886F6618EAC48510E79C32BA1@CRSMSX101.amr.corp.intel.com>
References: <20190306235455.26348-1-jhubbard@nvidia.com>
 <20190306235455.26348-2-jhubbard@nvidia.com>
 <010001695b3d2701-3215b423-7367-44d6-98bc-64fc2f84264a-000000@email.amazonses.com>
 <3cc3c382-2505-3b6c-ec58-1f14ebcb77e8@nvidia.com>
In-Reply-To: <3cc3c382-2505-3b6c-ec58-1f14ebcb77e8@nvidia.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiNGU2ZjFjZDUtOTZmMC00ZGUyLTk0NjAtMGFjNTc0MGZhZTU3IiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiUWRXQXFoQ291VXVPRWQrb2dSS1BiaGtyRTVlM2ZnOXZXZm5MK1dIb3M1TWlJVG9vc2RmeFZEbkFpZytLVFBZeiJ9
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.0.400.15
dlp-reaction: no-action
x-originating-ip: [172.18.205.10]
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

PiBTdWJqZWN0OiBSZTogW1BBVENIIHYzIDEvMV0gbW06IGludHJvZHVjZSBwdXRfdXNlcl9wYWdl
KigpLCBwbGFjZWhvbGRlcg0KPiB2ZXJzaW9ucw0KPiANCj4gT24gMy83LzE5IDY6NTggUE0sIENo
cmlzdG9waGVyIExhbWV0ZXIgd3JvdGU6DQo+ID4gT24gV2VkLCA2IE1hciAyMDE5LCBqb2huLmh1
YmJhcmRAZ21haWwuY29tIHdyb3RlOg0KPiA+DQo+ID4+IERhdmUgQ2hpbm5lcidzIGRlc2NyaXB0
aW9uIG9mIHRoaXMgaXMgdmVyeSBjbGVhcjoNCj4gPj4NCj4gPj4gICAgICJUaGUgZnVuZGFtZW50
YWwgaXNzdWUgaXMgdGhhdCAtPnBhZ2VfbWt3cml0ZSBtdXN0IGJlIGNhbGxlZCBvbiBldmVyeQ0K
PiA+PiAgICAgd3JpdGUgYWNjZXNzIHRvIGEgY2xlYW4gZmlsZSBiYWNrZWQgcGFnZSwgbm90IGp1
c3QgdGhlIGZpcnN0IG9uZS4NCj4gPj4gICAgIEhvdyBsb25nIHRoZSBHVVAgcmVmZXJlbmNlIGxh
c3RzIGlzIGlycmVsZXZhbnQsIGlmIHRoZSBwYWdlIGlzIGNsZWFuDQo+ID4+ICAgICBhbmQgeW91
IG5lZWQgdG8gZGlydHkgaXQsIHlvdSBtdXN0IGNhbGwgLT5wYWdlX21rd3JpdGUgYmVmb3JlIGl0
IGlzDQo+ID4+ICAgICBtYXJrZWQgd3JpdGVhYmxlIGFuZCBkaXJ0aWVkLiBFdmVyeS4gVGltZS4i
DQo+ID4+DQo+ID4+IFRoaXMgaXMganVzdCBvbmUgc3ltcHRvbSBvZiB0aGUgbGFyZ2VyIGRlc2ln
biBwcm9ibGVtOiBmaWxlc3lzdGVtcyBkbw0KPiA+PiBub3QgYWN0dWFsbHkgc3VwcG9ydCBnZXRf
dXNlcl9wYWdlcygpIGJlaW5nIGNhbGxlZCBvbiB0aGVpciBwYWdlcywNCj4gPj4gYW5kIGxldHRp
bmcgaGFyZHdhcmUgd3JpdGUgZGlyZWN0bHkgdG8gdGhvc2UgcGFnZXMtLWV2ZW4gdGhvdWdoIHRo
YXQNCj4gPj4gcGF0dGVyIGhhcyBiZWVuIGdvaW5nIG9uIHNpbmNlIGFib3V0IDIwMDUgb3Igc28u
DQo+ID4NCj4gPiBDYW4gd2UgZGlzdGluZ3Vpc2ggYmV0d2VlbiByZWFsIGZpbGVzeXN0ZW1zIHRo
YXQgYWN0dWFsbHkgd3JpdGUgdG8gYQ0KPiA+IGJhY2tpbmcgZGV2aWNlIGFuZCB0aGUgc3BlY2lh
bCBmaWxlc3lzdGVtcyAobGlrZSBodWdldGxiZnMsIHNobSBhbmQNCj4gPiBmcmllbmRzKSB0aGF0
IGFyZSBsaWtlIGFub255bW91cyBtZW1vcnkgYW5kIGRvIG5vdCByZXF1aXJlDQo+ID4gLT5wYWdl
X21rd3JpdGUoKSBpbiB0aGUgc2FtZSB3YXkgYXMgcmVndWxhciBmaWxlc3lzdGVtcz8NCj4gDQo+
IFllcy4gSSdsbCBjaGFuZ2UgdGhlIHdvcmRpbmcgaW4gdGhlIGNvbW1pdCBtZXNzYWdlIHRvIHNh
eSAicmVhbCBmaWxlc3lzdGVtcw0KPiB0aGF0IGFjdHVhbGx5IHdyaXRlIHRvIGEgYmFja2luZyBk
ZXZpY2UiLCBpbnN0ZWFkIG9mICJmaWxlc3lzdGVtcyIuIFRoYXQgZG9lcw0KPiBoZWxwLCB0aGFu
a3MuDQo+IA0KPiA+DQo+ID4gVGhlIHVzZSB0aGF0IEkgaGF2ZSBzZWVuIGluIG15IHNlY3Rpb24g
b2YgdGhlIHdvcmxkIGhhcyBiZWVuDQo+ID4gcmVzdHJpY3RlZCB0byBSRE1BIGFuZCBnZXRfdXNl
cl9wYWdlcyBiZWluZyBsaW1pdGVkIHRvIGFub255bW91cw0KPiA+IG1lbW9yeSBhbmQgdGhvc2Ug
c3BlY2lhbCBmaWxlc3lzdGVtcy4gQW5kIGlmIHRoZSBSRE1BIG1lbW9yeSBpcyBvZg0KPiA+IHN1
Y2ggdHlwZSB0aGVuIHRoZSB1c2UgaW4gdGhlIHBhc3QgYW5kIHByZXNlbnQgaXMgc2FmZS4NCj4g
DQo+IEFncmVlZC4NCj4gDQo+ID4NCj4gPiBTbyBhIGxvZ2ljYWwgb3RoZXIgYXBwcm9hY2ggd291
bGQgYmUgdG8gc2ltcGx5IG5vdCBhbGxvdyB0aGUgdXNlIG9mDQo+ID4gbG9uZyB0ZXJtIGdldF91
c2VyX3BhZ2UoKSBvbiByZWFsIGZpbGVzeXN0ZW0gcGFnZXMuIEkgaG9wZSB0aGlzIHBhdGNoDQo+
ID4gc3VwcG9ydHMgdGhhdD8NCj4gDQo+IFRoaXMgcGF0Y2ggbmVpdGhlciBwcmV2ZW50cyBub3Ig
cHJvdmlkZXMgdGhhdC4gV2hhdCB0aGlzIHBhdGNoIGRvZXMgaXMNCj4gcHJvdmlkZSBhIHByZXJl
cXVpc2l0ZSB0byBjbGVhciBpZGVudGlmaWNhdGlvbiBvZiBwYWdlcyB0aGF0IGhhdmUgaGFkDQo+
IGdldF91c2VyX3BhZ2VzKCkgY2FsbGVkIG9uIHRoZW0uDQo+IA0KPiANCj4gPg0KPiA+IEl0IGlz
IGN1c3RvbWFyeSBhZnRlciBhbGwgdGhhdCBhIGZpbGUgcmVhZCBvciB3cml0ZSBvcGVyYXRpb24g
aW52b2x2ZQ0KPiA+IG9uZSBzaW5nbGUgZmlsZSghKSBhbmQgdGhhdCB3aGF0IGlzIHdyaXR0ZW4g
ZWl0aGVyIGNvbWVzIGZyb20gb3IgZ29lcw0KPiA+IHRvIG1lbW9yeSAoYW5vbnltb3VzIG9yIHNw
ZWNpYWwgbWVtb3J5IGZpbGVzeXN0ZW0pLg0KPiA+DQo+ID4gSWYgeW91IGhhdmUgYW4gbW1hcHBl
ZCBtZW1vcnkgc2VnbWVudCB3aXRoIGEgcmVndWxhciBkZXZpY2UgYmFja2VkDQo+ID4gZmlsZSB0
aGVuIHlvdSBhbHJlYWR5IGhhdmUgb25lIGZpbGUgYXNzb2NpYXRlZCB3aXRoIGEgbWVtb3J5IHNl
Z21lbnQNCj4gPiBhbmQgYSBmaWxlc3lzdGVtIHRoYXQgZG9lcyB0YWtlIGNhcmUgb2Ygc3luY2hy
b25pemluZyB0aGUgY29udGVudHMgb2YNCj4gPiB0aGUgbWVtb3J5IHNlZ21lbnQgdG8gYSBiYWNr
aW5nIGRldmljZS4NCj4gPg0KPiA+IElmIHlvdSBub3cgcGVyZm9ybSBSRE1BIG9yIGRldmljZSBJ
L08gb24gc3VjaCBhIG1lbW9yeSBzZWdtZW50IHRoZW4NCj4gPiB5b3Ugd2lsbCBoYXZlICp0d28q
IGRpZmZlcmVudCBkZXZpY2VzIGludGVyYWN0aW5nIHdpdGggdGhhdCBtZW1vcnkNCj4gPiBzZWdt
ZW50LiBJIHRoaW5rIHRoYXQgb3VnaHQgbm90IHRvIGhhcHBlbiBhbmQgbm90IGJlIHN1cHBvcnRl
ZCBvdXQgb2YNCj4gPiB0aGUgYm94LiBJdCB3aWxsIGJlIGRpZmZpY3VsdCB0byBoYW5kbGUgYW5k
IHRoZSBzZW1hbnRpY3Mgd2lsbCBiZSBoYXJkDQo+ID4gZm9yIHVzZXJzIHRvIHVuZGVyc3RhbmQu
DQo+ID4NCj4gPiBXaGF0IGNvdWxkIGhhcHBlbiBpcyB0aGF0IHRoZSBmaWxlc3lzdGVtIGNvdWxk
IGFncmVlIG9uIHJlcXVlc3QgdG8NCj4gPiBhbGxvdyB0aGlyZCBwYXJ0eSBJL08gdG8gZ28gdG8g
c3VjaCBhIG1lbW9yeSBzZWdtZW50LiBCdXQgdGhhdCBuZWVkcw0KPiA+IHRvIGJlIHdlbGwgZGVm
aW5lZCBhbmQgY2xlYXJseSBhbmQgZXhwbGljaXRseSBoYW5kbGVkIGJ5IHNvbWUNCj4gPiBtZWNo
YW5pc20gaW4gdXNlciBzcGFjZSB0aGF0IGhhcyB3ZWxsIGRlZmluZWQgc2VtYW50aWNzIGZvciBk
YXRhDQo+ID4gaW50ZWdyaXR5IGZvciB0aGUgZmlsZXN5c3RlbSBhcyB3ZWxsIGFzIHRoZSBSRE1B
IG9yIGRldmljZSBJL08uDQo+ID4NCj4gDQo+IFRob3NlIGRpc2N1c3Npb25zIGFyZSB1bmRlcndh
eS4gRGF2ZSBDaGlubmVyIGFuZCBvdGhlcnMgaGF2ZSBiZWVuIHRhbGtpbmcNCj4gYWJvdXQgZmls
ZXN5c3RlbSBsZWFzZXMsIGZvciBleGFtcGxlLiBUaGUga2V5IHBvaW50IGhlcmUgaXMgdGhhdCB3
ZSdsbCBzdGlsbA0KPiBuZWVkLCBpbiBhbnkgb2YgdGhlc2UgYXBwcm9hY2hlcywgdG8gYmUgYWJs
ZSB0byBpZGVudGlmeSB0aGUgZ3VwLXBpbm5lZCBwYWdlcy4NCj4gQW5kIHRoZXJlIGFyZSBsb3Rz
ICgxMDArKSBvZiBjYWxsIHNpdGVzIHRvIGNoYW5nZS4gU28gSSBmaWd1cmUgd2UnZCBiZXR0ZXIg
Z2V0DQo+IHRoYXQgc3RhcnRlZC4NCj4NCg0KKyAxDQoNCkknbSBleHBsb3JpbmcgcGF0Y2ggc2V0
cyBsaWtlIHRoaXMuICBIYXZpbmcgdGhpcyBpbnRlcmZhY2UgYXZhaWxhYmxlIHdpbGwsIElNTywg
YWxsb3cgZm9yIGJldHRlciByZXZpZXcgb2YgdGhvc2UgcGF0Y2hlcyByYXRoZXIgdGhhbiBzYXlp
bmcgImdvIG92ZXIgdG8gSm9obnMgdHJlZSB0byBnZXQgdGhlIHByZS1yZXF1aXNpdGUgcGF0Y2hl
cyIuICA6LUQNCg0KQWxzbyBJIHRoaW5rIGl0IHdpbGwgYmUgZWFzaWVyIGZvciB1c2VycyB0byBn
ZXQgdGhpbmdzIHJpZ2h0IGJ5IGNhbGxpbmcgW2dldHxwdXRdX3VzZXJfcGFnZXMoKSByYXRoZXIg
dGhhbiBnZXRfdXNlcl9wYWdlcygpIGZvbGxvd2VkIGJ5IHB1dF9wYWdlKCkuDQoNCklyYQ0KDQo+
IHRoYW5rcywNCj4gLS0NCj4gSm9obiBIdWJiYXJkDQo+IE5WSURJQQ0K

