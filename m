Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7DAAC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 22:56:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57488217F5
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 22:56:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57488217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E9F508E000A; Mon, 25 Feb 2019 17:56:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4E5A8E0005; Mon, 25 Feb 2019 17:56:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF2978E000A; Mon, 25 Feb 2019 17:56:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8B0B08E0005
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 17:56:31 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id a5so8928455pfn.2
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 14:56:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:user-agent:content-id
         :content-transfer-encoding:mime-version;
        bh=0359tmBJxaW2ppo3QtNsq/BeQT/EtCAwxZDcqafN1r4=;
        b=Haybq+UuzXAVzl8qDOzKehaltY8fyi4HDhZsoDm4P4qNpGiK3dCPe/NKdWwYsl92KI
         yxxxW+2dqSkkb5n5PREll3sW0bC9lxIALJc0bxZYrvDjgc79xxscibD4RPC7vzruHt3n
         K4NvZH1LmwXEBAcpFiGqjWyS0f2YsiUm6B4ZPQnkiiL47W3+FSZziB/nxefGOsYGMkR3
         hlLh9UZUm1qSlorDncv0gNjwaBy5+Lx8o+T/BvdDyadCd6Spvaup6il4UsbDOw2CVYiZ
         z36TJWReRNAzWahxQCqm8RymdoyqttF5cP0o0RdUXCTorVLDDP/kx9OxmR57xkz4sxB4
         lrLg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vishal.l.verma@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=vishal.l.verma@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAua/Ea5ztKOooEgpQfVX9wQyLSZeg1LwocboOAXw/v16f/frerpv
	pT8sPM6rov/AILbPUkDNoJEeyByQLjXy1WxAvr7Pp5/WlVcgGolO53ZgTJmwXbqGOxUp9CBTsI3
	jN0bqI2d0SBJDPVRPgcxlG4Z+6MaVXj+qYqOZpvfGDF0yHkWT53MByWNWMNA6Y+Bq/A==
X-Received: by 2002:a17:902:e01:: with SMTP id 1mr5859949plw.66.1551135391167;
        Mon, 25 Feb 2019 14:56:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibfx0zCefZwA05syRJQiymRcCpfvhWfQ+JbzT5Yz5Xw/V70ipWfaH5bQhS//fpOTPC7rdWh
X-Received: by 2002:a17:902:e01:: with SMTP id 1mr5859848plw.66.1551135389998;
        Mon, 25 Feb 2019 14:56:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551135389; cv=none;
        d=google.com; s=arc-20160816;
        b=kPfR10Mi8njdlD56hq45AgNynV6IEiEFdClaolPWuF11yg6iha1sm46YHNGu2gVFqM
         cjAQ/X2qkrs99qNGgv5Jj68dtKLilcthwWrqb35DieJ1a8+nVEMvJNZs2jD+iUqQN5a/
         yu3KLI7LPolq+hu8ryJVq/2c1G5c/i+8+ITZaVQVJPnCT36A0XJLjqJ3qJvtIYGkHJ7y
         3Hacq5MiqEQ51XxulVKZtQATWKgOqAPTxQ2qKerBWKJSKkQTAbP75fx80R7VNBEye8mX
         M+W292GM465SvWBk6z2RxDy5sTea578JV5+exRHHP8Fh4DRHNXSd/47gBGMs4DetHALA
         hxRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from;
        bh=0359tmBJxaW2ppo3QtNsq/BeQT/EtCAwxZDcqafN1r4=;
        b=Po2rv9jrS69pw2VOqCuFoWjjPXWzOlbQaFItv/v3gun/XbXSYQr0Ao5viL+av+AeUX
         9aof6BIEax9ySzsH0jy6q+mlzdxW/G6dh4XEur/SalfyXp7sC+kG9XJP43SdkZ28HgfW
         FLk5/emCXv6DurAAHgqUzi1W9TTzMXgVLUh1Ea0I7eJpvnnTr4j//2Bxcya+xcLdBhxh
         Gwd96C+/S67xXTX8pmkTGf23WU/SqUVhrO1slK3Db5aLj6ZCoqLYSw4iz5tq+bJg1oqN
         596WINN4amlqWvaYswP5te2xYrXyVTIVjqf4ciL7EixLB/F8hJBge4nNR3hyQLpMygG1
         sAzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vishal.l.verma@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=vishal.l.verma@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id f11si11143529pgl.594.2019.02.25.14.56.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 14:56:29 -0800 (PST)
Received-SPF: pass (google.com: domain of vishal.l.verma@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vishal.l.verma@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=vishal.l.verma@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Feb 2019 14:56:29 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,413,1544515200"; 
   d="scan'208";a="322044552"
Received: from fmsmsx103.amr.corp.intel.com ([10.18.124.201])
  by fmsmga006.fm.intel.com with ESMTP; 25 Feb 2019 14:56:28 -0800
Received: from fmsmsx154.amr.corp.intel.com (10.18.116.70) by
 FMSMSX103.amr.corp.intel.com (10.18.124.201) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Mon, 25 Feb 2019 14:56:28 -0800
Received: from fmsmsx113.amr.corp.intel.com ([169.254.13.220]) by
 FMSMSX154.amr.corp.intel.com ([169.254.6.137]) with mapi id 14.03.0415.000;
 Mon, 25 Feb 2019 14:56:27 -0800
From: "Verma, Vishal L" <vishal.l.verma@intel.com>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>
CC: "tiwai@suse.de" <tiwai@suse.de>, "bp@suse.de" <bp@suse.de>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "Williams, Dan J"
	<dan.j.williams@intel.com>, "akpm@linux-foundation.org"
	<akpm@linux-foundation.org>, "linux-nvdimm@lists.01.org"
	<linux-nvdimm@lists.01.org>, "jglisse@redhat.com" <jglisse@redhat.com>,
	"zwisler@kernel.org" <zwisler@kernel.org>, "mhocko@suse.com"
	<mhocko@suse.com>, "Jiang, Dave" <dave.jiang@intel.com>,
	"bhelgaas@google.com" <bhelgaas@google.com>, "thomas.lendacky@amd.com"
	<thomas.lendacky@amd.com>, "Busch, Keith" <keith.busch@intel.com>, "Huang,
 Ying" <ying.huang@intel.com>, "Wu, Fengguang" <fengguang.wu@intel.com>,
	"baiyaowei@cmss.chinamobile.com" <baiyaowei@cmss.chinamobile.com>
Subject: Re: [PATCH 5/5] dax: "Hotplug" persistent memory for use like
 normal RAM
Thread-Topic: [PATCH 5/5] dax: "Hotplug" persistent memory for use like
 normal RAM
Thread-Index: AQHUzTy2FiMXDR4hAUGjkAERKXAVEaXxpk2A
Date: Mon, 25 Feb 2019 22:56:27 +0000
Message-ID: <68f1da72779fcbb8b0cab8ab5927b918c3ea9711.camel@intel.com>
References: <20190225185727.BCBD768C@viggo.jf.intel.com>
	 <20190225185740.8660866F@viggo.jf.intel.com>
In-Reply-To: <20190225185740.8660866F@viggo.jf.intel.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Evolution 3.30.5 (3.30.5-1.fc29) 
x-originating-ip: [10.232.112.185]
Content-Type: text/plain; charset="utf-8"
Content-ID: <E0D2C7A58BCF55448C6199F41E0F97E9@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

DQpPbiBNb24sIDIwMTktMDItMjUgYXQgMTA6NTcgLTA4MDAsIERhdmUgSGFuc2VuIHdyb3RlOg0K
PiBGcm9tOiBEYXZlIEhhbnNlbiA8ZGF2ZS5oYW5zZW5AbGludXguaW50ZWwuY29tPg0KPiANCj4g
VGhpcyBpcyBpbnRlbmRlZCBmb3IgdXNlIHdpdGggTlZESU1NcyB0aGF0IGFyZSBwaHlzaWNhbGx5
IHBlcnNpc3RlbnQNCj4gKHBoeXNpY2FsbHkgbGlrZSBmbGFzaCkgc28gdGhhdCB0aGV5IGNhbiBi
ZSB1c2VkIGFzIGEgY29zdC1lZmZlY3RpdmUNCj4gUkFNIHJlcGxhY2VtZW50LiAgSW50ZWwgT3B0
YW5lIERDIHBlcnNpc3RlbnQgbWVtb3J5IGlzIG9uZQ0KPiBpbXBsZW1lbnRhdGlvbiBvZiB0aGlz
IGtpbmQgb2YgTlZESU1NLg0KPiANCj4gQ3VycmVudGx5LCBhIHBlcnNpc3RlbnQgbWVtb3J5IHJl
Z2lvbiBpcyAib3duZWQiIGJ5IGEgZGV2aWNlIGRyaXZlciwNCj4gZWl0aGVyIHRoZSAiRGlyZWN0
IERBWCIgb3IgIkZpbGVzeXN0ZW0gREFYIiBkcml2ZXJzLiAgVGhlc2UgZHJpdmVycw0KPiBhbGxv
dyBhcHBsaWNhdGlvbnMgdG8gZXhwbGljaXRseSB1c2UgcGVyc2lzdGVudCBtZW1vcnksIGdlbmVy
YWxseQ0KPiBieSBiZWluZyBtb2RpZmllZCB0byB1c2Ugc3BlY2lhbCwgbmV3IGxpYnJhcmllcy4g
KERJTU0tYmFzZWQNCj4gcGVyc2lzdGVudCBtZW1vcnkgaGFyZHdhcmUvc29mdHdhcmUgaXMgZGVz
Y3JpYmVkIGluIGdyZWF0IGRldGFpbA0KPiBoZXJlOiBEb2N1bWVudGF0aW9uL252ZGltbS9udmRp
bW0udHh0KS4NCj4gDQo+IEhvd2V2ZXIsIHRoaXMgbGltaXRzIHBlcnNpc3RlbnQgbWVtb3J5IHVz
ZSB0byBhcHBsaWNhdGlvbnMgd2hpY2gNCj4gKmhhdmUqIGJlZW4gbW9kaWZpZWQuICBUbyBtYWtl
IGl0IG1vcmUgYnJvYWRseSB1c2FibGUsIHRoaXMgZHJpdmVyDQo+ICJob3RwbHVncyIgbWVtb3J5
IGludG8gdGhlIGtlcm5lbCwgdG8gYmUgbWFuYWdlZCBhbmQgdXNlZCBqdXN0IGxpa2UNCj4gbm9y
bWFsIFJBTSB3b3VsZCBiZS4NCj4gDQo+IFRvIG1ha2UgdGhpcyB3b3JrLCBtYW5hZ2VtZW50IHNv
ZnR3YXJlIG11c3QgcmVtb3ZlIHRoZSBkZXZpY2UgZnJvbQ0KPiBiZWluZyBjb250cm9sbGVkIGJ5
IHRoZSAiRGV2aWNlIERBWCIgaW5mcmFzdHJ1Y3R1cmU6DQo+IA0KPiAJZWNobyBkYXgwLjAgPiAv
c3lzL2J1cy9kYXgvZHJpdmVycy9kZXZpY2VfZGF4L3VuYmluZA0KPiANCj4gYW5kIHRoZW4gdGVs
bCB0aGUgbmV3IGRyaXZlciB0aGF0IGl0IGNhbiBiaW5kIHRvIHRoZSBkZXZpY2U6DQo+IA0KPiAJ
ZWNobyBkYXgwLjAgPiAvc3lzL2J1cy9kYXgvZHJpdmVycy9rbWVtL25ld19pZA0KPiANCj4gQWZ0
ZXIgdGhpcywgdGhlcmUgd2lsbCBiZSBhIG51bWJlciBvZiBuZXcgbWVtb3J5IHNlY3Rpb25zIHZp
c2libGUNCj4gaW4gc3lzZnMgdGhhdCBjYW4gYmUgb25saW5lZCwgb3IgdGhhdCBtYXkgZ2V0IG9u
bGluZWQgYnkgZXhpc3RpbmcNCj4gdWRldi1pbml0aWF0ZWQgbWVtb3J5IGhvdHBsdWcgcnVsZXMu
DQo+IA0KPiBUaGlzIHJlYmluZGluZyBwcm9jZWR1cmUgaXMgY3VycmVudGx5IGEgb25lLXdheSB0
cmlwLiAgT25jZSBtZW1vcnkNCj4gaXMgYm91bmQgdG8gImttZW0iLCBpdCdzIHRoZXJlIHBlcm1h
bmVudGx5IGFuZCBjYW4gbm90IGJlDQo+IHVuYm91bmQgYW5kIGFzc2lnbmVkIGJhY2sgdG8gZGV2
aWNlX2RheC4NCj4gDQo+IFRoZSBrbWVtIGRyaXZlciB3aWxsIG5ldmVyIGJpbmQgdG8gYSBkYXgg
ZGV2aWNlIHVubGVzcyB0aGUgZGV2aWNlDQo+IGlzICpleHBsaWNpdGx5KiBib3VuZCB0byB0aGUg
ZHJpdmVyLiAgVGhlcmUgYXJlIHR3byByZWFzb25zIGZvcg0KPiB0aGlzOiBPbmUsIHNpbmNlIGl0
IGlzIGEgb25lLXdheSB0cmlwLCBpdCBjYW4gbm90IGJlIHVuZG9uZSBpZg0KPiBib3VuZCBpbmNv
cnJlY3RseS4gIFR3bywgdGhlIGttZW0gZHJpdmVyIGRlc3Ryb3lzIGRhdGEgb24gdGhlDQo+IGRl
dmljZS4gIFRoaW5rIG9mIGlmIHlvdSBoYWQgZ29vZCBkYXRhIG9uIGEgcG1lbSBkZXZpY2UuICBJ
dA0KPiB3b3VsZCBiZSBjYXRhc3Ryb3BoaWMgaWYgeW91IGNvbXBpbGUtaW4gImttZW0iLCBidXQg
bGVhdmUgb3V0DQo+IHRoZSAiZGV2aWNlX2RheCIgZHJpdmVyLiAga21lbSB3b3VsZCB0YWtlIG92
ZXIgdGhlIGRldmljZSBhbmQNCj4gd3JpdGUgdm9sYXRpbGUgZGF0YSBhbGwgb3ZlciB5b3VyIGdv
b2QgZGF0YS4NCj4gDQo+IFRoaXMgaW5oZXJpdHMgYW55IGV4aXN0aW5nIE5VTUEgaW5mb3JtYXRp
b24gZm9yIHRoZSBuZXdseS1hZGRlZA0KPiBtZW1vcnkgZnJvbSB0aGUgcGVyc2lzdGVudCBtZW1v
cnkgZGV2aWNlIHRoYXQgY2FtZSBmcm9tIHRoZQ0KPiBmaXJtd2FyZS4gIE9uIEludGVsIHBsYXRm
b3JtcywgdGhlIGZpcm13YXJlIGhhcyBndWFyYW50ZWVzIHRoYXQNCj4gcmVxdWlyZSBlYWNoIHNv
Y2tldCdzIHBlcnNpc3RlbnQgbWVtb3J5IHRvIGJlIGluIGEgc2VwYXJhdGUNCj4gbWVtb3J5LW9u
bHkgTlVNQSBub2RlLiAgVGhhdCBtZWFucyB0aGF0IHRoaXMgcGF0Y2ggaXMgbm90IGV4cGVjdGVk
DQo+IHRvIGNyZWF0ZSBOVU1BIG5vZGVzLCBidXQgd2lsbCBzaW1wbHkgaG90cGx1ZyBtZW1vcnkg
aW50byBleGlzdGluZw0KPiBub2Rlcy4NCj4gDQo+IEJlY2F1c2UgTlVNQSBub2RlcyBhcmUgY3Jl
YXRlZCwgdGhlIGV4aXN0aW5nIE5VTUEgQVBJcyBhbmQgdG9vbHMNCj4gYXJlIHN1ZmZpY2llbnQg
dG8gY3JlYXRlIHBvbGljaWVzIGZvciBhcHBsaWNhdGlvbnMgb3IgbWVtb3J5IGFyZWFzDQo+IHRv
IGhhdmUgYWZmaW5pdHkgZm9yIG9yIGFuIGF2ZXJzaW9uIHRvIHVzaW5nIHRoaXMgbWVtb3J5Lg0K
PiANCj4gVGhlcmUgaXMgY3VycmVudGx5IHNvbWUgbWV0YWRhdGEgYXQgdGhlIGJlZ2lubmluZyBv
ZiBwbWVtIHJlZ2lvbnMuDQo+IFRoZSBzZWN0aW9uLXNpemUgbWVtb3J5IGhvdHBsdWcgcmVzdHJp
Y3Rpb25zLCBwbHVzIHRoaXMgc21hbGwNCj4gcmVzZXJ2ZWQgYXJlYSBjYW4gY2F1c2UgdGhlICJs
b3NzIiBvZiBhIHNlY3Rpb24gb3IgdHdvIG9mIGNhcGFjaXR5Lg0KPiBUaGlzIHNob3VsZCBiZSBm
aXhhYmxlIGluIGZvbGxvdy1vbiBwYXRjaGVzLiAgQnV0LCBhcyBhIGZpcnN0IHN0ZXAsDQo+IGxv
c2luZyAyNTZNQiBvZiBtZW1vcnkgKHdvcnN0IGNhc2UpIG91dCBvZiBodW5kcmVkcyBvZiBnaWdh
Ynl0ZXMNCj4gaXMgYSBnb29kIHRyYWRlb2ZmIHZzLiB0aGUgcmVxdWlyZWQgY29kZSB0byBmaXgg
dGhpcyB1cCBwcmVjaXNlbHkuDQo+IFRoaXMgY2FsY3VsYXRpb24gaXMgYWxzbyB0aGUgcmVhc29u
IHdlIGV4cG9ydA0KPiBtZW1vcnlfYmxvY2tfc2l6ZV9ieXRlcygpLg0KPiANCj4gU2lnbmVkLW9m
Zi1ieTogRGF2ZSBIYW5zZW4gPGRhdmUuaGFuc2VuQGxpbnV4LmludGVsLmNvbT4NCj4gUmV2aWV3
ZWQtYnk6IERhbiBXaWxsaWFtcyA8ZGFuLmoud2lsbGlhbXNAaW50ZWwuY29tPg0KPiBSZXZpZXdl
ZC1ieTogS2VpdGggQnVzY2ggPGtlaXRoLmJ1c2NoQGludGVsLmNvbT4NCj4gQ2M6IERhdmUgSmlh
bmcgPGRhdmUuamlhbmdAaW50ZWwuY29tPg0KPiBDYzogUm9zcyBad2lzbGVyIDx6d2lzbGVyQGtl
cm5lbC5vcmc+DQo+IENjOiBWaXNoYWwgVmVybWEgPHZpc2hhbC5sLnZlcm1hQGludGVsLmNvbT4N
Cj4gQ2M6IFRvbSBMZW5kYWNreSA8dGhvbWFzLmxlbmRhY2t5QGFtZC5jb20+DQo+IENjOiBBbmRy
ZXcgTW9ydG9uIDxha3BtQGxpbnV4LWZvdW5kYXRpb24ub3JnPg0KPiBDYzogTWljaGFsIEhvY2tv
IDxtaG9ja29Ac3VzZS5jb20+DQo+IENjOiBsaW51eC1udmRpbW1AbGlzdHMuMDEub3JnDQo+IENj
OiBsaW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnDQo+IENjOiBsaW51eC1tbUBrdmFjay5vcmcN
Cj4gQ2M6IEh1YW5nIFlpbmcgPHlpbmcuaHVhbmdAaW50ZWwuY29tPg0KPiBDYzogRmVuZ2d1YW5n
IFd1IDxmZW5nZ3Vhbmcud3VAaW50ZWwuY29tPg0KPiBDYzogQm9yaXNsYXYgUGV0a292IDxicEBz
dXNlLmRlPg0KPiBDYzogQmpvcm4gSGVsZ2FhcyA8YmhlbGdhYXNAZ29vZ2xlLmNvbT4NCj4gQ2M6
IFlhb3dlaSBCYWkgPGJhaXlhb3dlaUBjbXNzLmNoaW5hbW9iaWxlLmNvbT4NCj4gQ2M6IFRha2Fz
aGkgSXdhaSA8dGl3YWlAc3VzZS5kZT4NCj4gQ2M6IEplcm9tZSBHbGlzc2UgPGpnbGlzc2VAcmVk
aGF0LmNvbT4NCj4gLS0tDQo+IA0KPiAgYi9kcml2ZXJzL2Jhc2UvbWVtb3J5LmMgfCAgICAxIA0K
PiAgYi9kcml2ZXJzL2RheC9LY29uZmlnICAgfCAgIDE2ICsrKysrKysNCj4gIGIvZHJpdmVycy9k
YXgvTWFrZWZpbGUgIHwgICAgMSANCj4gIGIvZHJpdmVycy9kYXgva21lbS5jICAgIHwgIDEwOCAr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysNCj4gIDQgZmls
ZXMgY2hhbmdlZCwgMTI2IGluc2VydGlvbnMoKykNCg0KTG9va3MgZ29vZCwNClJldmlld2VkLWJ5
OiBWaXNoYWwgVmVybWEgPHZpc2hhbC5sLnZlcm1hQGludGVsLmNvbT4NCg0KDQo=

