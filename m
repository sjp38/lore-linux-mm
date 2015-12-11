Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3D3A46B0253
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 16:01:51 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so70705442pac.1
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 13:01:51 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id rf10si3351326pab.94.2015.12.11.13.01.50
        for <linux-mm@kvack.org>;
        Fri, 11 Dec 2015 13:01:50 -0800 (PST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCHV2 1/3] x86, ras: Add new infrastructure for machine
 check fixup tables
Date: Fri, 11 Dec 2015 21:01:49 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F39F82D35@ORSMSX114.amr.corp.intel.com>
References: <cover.1449861203.git.tony.luck@intel.com>
 <456153d09e85f2f139020a051caed3ca8f8fca73.1449861203.git.tony.luck@intel.com>
 <CALCETrUO+g9HbPa8yaA=1JpVxw9ReSvgokT_GDKwePigyGoZLQ@mail.gmail.com>
In-Reply-To: <CALCETrUO+g9HbPa8yaA=1JpVxw9ReSvgokT_GDKwePigyGoZLQ@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew
 Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

Pj4gKyAgICAgICAgICAgICAgIHJlZ3MtPmlwID0gbmV3X2lwOw0KPj4gKyAgICAgICAgICAgICAg
IHJlZ3MtPmF4ID0gQklUKDYzKSB8IGFkZHI7DQo+DQo+IENhbiB0aGlzIGJlIGFuIGFjdHVhbCAj
ZGVmaW5lPw0KDQpEb2ghICBZZXMsIG9mIGNvdXJzZS4gVGhhdCB3b3VsZCBiZSBtdWNoIGJldHRl
ci4NCg0KTm93IEkgbmVlZCB0byB0aGluayBvZiBhIGdvb2QgbmFtZSBmb3IgaXQuDQoNCi1Ub255
DQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
