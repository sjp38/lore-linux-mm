Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94A35C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:27:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D1D321B25
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:27:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D1D321B25
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E095F8E0144; Mon, 11 Feb 2019 14:27:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8F8A8E0134; Mon, 11 Feb 2019 14:27:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C0A008E0144; Mon, 11 Feb 2019 14:27:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7A8B88E0134
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:27:06 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id d3so2553pgv.23
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:27:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=U397cR9eTKWmqRbop+UwUyvrCSeJeMYvLk5k8p9ksU8=;
        b=QdCSpb9gVMkkkHMBm/twOacwPHvtbXPCq+kLCZudwXEkHOMJzEba9KdpRhI71KWv9I
         P6TCQIe5EvbXHUprOjC4hLHzLI1aWM3VbBV1gz8M1buHIaLa4LwNh5HuPHOeMaA/lPB5
         va4MfPlUcxQogQpLOG6sxB5vfYYxcU3uUcQz9sVPnj7ltJlaKlvwQjuJzXH3vuOexFLM
         Hqk2f9BXh5ODNsTjF/1xm77TMS+AGiAwBv/TiprcPkT566Qlq9KmGZMvSdU2gBUKidkl
         BWTjVb6iKQ19LFuYPRCM8Y43xEMmmZaNe834AELewEt0lmWHyaICB21nG2lOi7YlUPgX
         olgA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuavakX8pZDAoCpLfATUW8YqGzz5u/TY1XgMNcfRaqUraY57J4lR
	NRgT5m0VymwhQ6cawu660zwMfPSt+ZuFDdD9ZoXb5LAzzy42X1IzStNngAJnBVzFiC1R1VFJ97H
	/C4H0718VN+EYkEimEbG5LJ20sGtIcte4QQx86JaW77XdIv9Nftt0UpSUewEpUflsZA==
X-Received: by 2002:a17:902:6bc9:: with SMTP id m9mr38568266plt.173.1549913226132;
        Mon, 11 Feb 2019 11:27:06 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbaeU3Ev1bDR4LYj1XdlvP+P9yGs8P6hWMuN7sLd7iyvWF7CgRr4+9VHuNFj5CTrCbBc+Hj
X-Received: by 2002:a17:902:6bc9:: with SMTP id m9mr38568230plt.173.1549913225544;
        Mon, 11 Feb 2019 11:27:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549913225; cv=none;
        d=google.com; s=arc-20160816;
        b=LGDIzazv/tyutbpGPkSE9D3C874Q+m1Joxb8C5a4SUKhGC7OTpakdHTDklrUTWmnZQ
         yfCxbkXqg68UOVA1/1W9RVLE0THqPxZp1iT7MjmYSjvc7jNUaLCZmxaVFqPZbtMXdxHl
         XSFOhzEkqzuQ5t2oZqXJ5ceLHtJmf+x2Y2h4Ctw1DgAgN4CeM4IQDRCe5NQ81kaPr6HS
         D08cMlV/o84WNsF3Uia4SOEaAwXZfKmHGyArZM9f7qqESzoNkUvL5pNF0BZOZUKsc9Vw
         2FlEQnsiHWkGkYDI3IYlYsfn+Udh7IpjhpWNLeub1tz5MuHmniEr8IRbzJoISoEsE19L
         4E8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=U397cR9eTKWmqRbop+UwUyvrCSeJeMYvLk5k8p9ksU8=;
        b=EPKR1X6NMckGTSnMy94hkPcyN7nLUpm2syfxCSikSm6MUUSowEPNrqteQqtxWYgj6k
         dPdZ5vDFZ97mC1sYtpkcpuhGu0IfZV6IBpT1qiZGreGOCRGww1IkwktgXkihi22cOL+h
         aF+jOZk58lSRBYrynmn3mUBD/xAS362du487Jfqe44ELJ4nRS0w12U3e4MEGRqxpOJNa
         L/La5Ua5W9iggORByLGKOKPAAnb48Zw9DsowqNz2NKZbkOHCSLy0J1WwORt/+vehQMOk
         uWUKjpDgEOQ0k4VXbWG7GXaUb8PqUc3NgbYRgjCqUlDAZc5BqgosBB7V0AfFjy5jSW8W
         W1Vw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id c1si446948plr.55.2019.02.11.11.27.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 11:27:05 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 11:27:05 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,359,1544515200"; 
   d="scan'208";a="319486949"
Received: from orsmsx110.amr.corp.intel.com ([10.22.240.8])
  by fmsmga005.fm.intel.com with ESMTP; 11 Feb 2019 11:27:04 -0800
Received: from orsmsx154.amr.corp.intel.com (10.22.226.12) by
 ORSMSX110.amr.corp.intel.com (10.22.240.8) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Mon, 11 Feb 2019 11:27:03 -0800
Received: from orsmsx112.amr.corp.intel.com ([169.254.3.70]) by
 ORSMSX154.amr.corp.intel.com ([169.254.11.122]) with mapi id 14.03.0415.000;
 Mon, 11 Feb 2019 11:27:03 -0800
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
To: "bp@alien8.de" <bp@alien8.de>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"linux-integrity@vger.kernel.org" <linux-integrity@vger.kernel.org>,
	"ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "tglx@linutronix.de"
	<tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>,
	"nadav.amit@gmail.com" <nadav.amit@gmail.com>, "Dock, Deneen T"
	<deneen.t.dock@intel.com>, "linux-security-module@vger.kernel.org"
	<linux-security-module@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com"
	<hpa@zytor.com>, "kristen@linux.intel.com" <kristen@linux.intel.com>,
	"mingo@redhat.com" <mingo@redhat.com>, "linux_dti@icloud.com"
	<linux_dti@icloud.com>, "luto@kernel.org" <luto@kernel.org>,
	"will.deacon@arm.com" <will.deacon@arm.com>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>
Subject: Re: [PATCH v2 13/20] Add set_alias_ function and x86 implementation
Thread-Topic: [PATCH v2 13/20] Add set_alias_ function and x86 implementation
Thread-Index: AQHUt2sVkrG1Bgg4x0e07u2CUOZGlKXbkeGAgAAE7gA=
Date: Mon, 11 Feb 2019 19:27:03 +0000
Message-ID: <468a81ee8983a7dfc3e5ab5c269fc89ff16b6b21.camel@intel.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
	 <20190129003422.9328-14-rick.p.edgecombe@intel.com>
	 <20190211190925.GQ19618@zn.tnic>
In-Reply-To: <20190211190925.GQ19618@zn.tnic>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.54.75.11]
Content-Type: text/plain; charset="utf-8"
Content-ID: <112F179FA06F5143B572137122F136C3@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gTW9uLCAyMDE5LTAyLTExIGF0IDIwOjA5ICswMTAwLCBCb3Jpc2xhdiBQZXRrb3Ygd3JvdGU6
DQo+IE9uIE1vbiwgSmFuIDI4LCAyMDE5IGF0IDA0OjM0OjE1UE0gLTA4MDAsIFJpY2sgRWRnZWNv
bWJlIHdyb3RlOg0KPiA+IFRoaXMgYWRkcyB0d28gbmV3IGZ1bmN0aW9ucyBzZXRfYWxpYXNfZGVm
YXVsdF9ub2ZsdXNoIGFuZA0KPiANCj4gcy9UaGlzIGFkZHMvQWRkLw0KPiANCj4gPiBzZXRfYWxp
YXNfbnZfbm9mbHVzaCBmb3Igc2V0dGluZyB0aGUgYWxpYXMgbWFwcGluZyBmb3IgdGhlIHBhZ2Ug
dG8gaXRzDQo+IA0KPiBQbGVhc2UgZW5kIGZ1bmN0aW9uIG5hbWVzIHdpdGggcGFyZW50aGVzZXMs
IGJlbG93IHRvby4NCk9rLg0KPiA+IGRlZmF1bHQgdmFsaWQgcGVybWlzc2lvbnMgYW5kIHRvIGFu
IGludmFsaWQgc3RhdGUgdGhhdCBjYW5ub3QgYmUgY2FjaGVkIGluDQo+ID4gYSBUTEIsIHJlc3Bl
Y3RpdmVseS4gVGhlc2UgZnVuY3Rpb25zIHRvIG5vdCBmbHVzaCB0aGUgVExCLg0KPiANCj4gcy90
by9kby8NCj4gDQpBcmdoLCB0aGFua3MuDQo+IEFsc28sIHBscyBwdXQgdGhhdCBkZXNjcmlwdGlv
biBhcyBjb21tZW50cyBvdmVyIHRoZSBmdW5jdGlvbnMgaW4gdGhlDQo+IGNvZGUuIE90aGVyd2lz
ZSB0aGF0ICJudiIgYXMgcGFydCBvZiB0aGUgbmFtZSBkb2Vzbid0IHJlYWxseSBleHBsYWluDQo+
IHdoYXQgaXQgZG9lcy4NCj4gDQo+IEFjdHVhbGx5LCB5b3UgY291bGQganVzdCBhcyB3ZWxsIGNh
bGwgdGhlIGZ1bmN0aW9uDQo+IA0KPiBzZXRfYWxpYXNfaW52YWxpZF9ub2ZsdXNoKCkNCj4gDQo+
IEFsbCB0aGUgb3RoZXIgd29yZHMgYXJlIHdyaXR0ZW4gaW4gZnVsbCwgbm8gbmVlZCB0byBoYXZl
ICJudiIgdGhlcmUuDQo+IA0KPiBUaHguDQpZZXMsIHRoYXQgc2VlbXMgYmV0dGVyLg0KDQpUaGFu
a3MsDQoNClJpY2sNCg==

