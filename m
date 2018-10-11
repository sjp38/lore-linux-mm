Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id B8BA76B000A
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 08:18:23 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id g133-v6so7576626ioa.12
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 05:18:23 -0700 (PDT)
Received: from CAN01-QB1-obe.outbound.protection.outlook.com (mail-eopbgr660134.outbound.protection.outlook.com. [40.107.66.134])
        by mx.google.com with ESMTPS id f26-v6si23182885jam.72.2018.10.11.05.18.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 11 Oct 2018 05:18:22 -0700 (PDT)
From: "Stephen  Bates" <sbates@raithlin.com>
Subject: Re: [PATCH 5/5] RISC-V: Implement sparsemem
Date: Thu, 11 Oct 2018 12:18:20 +0000
Message-ID: <15C8B877-4BBE-47E1-98D1-945E9355E757@raithlin.com>
References: <20181005161642.2462-6-logang@deltatee.com>
 <mhng-c93e2f59-7121-4964-bd61-3c4c02044cf3@palmer-si-x1c4>
In-Reply-To: <mhng-c93e2f59-7121-4964-bd61-3c4c02044cf3@palmer-si-x1c4>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <352AFE9402187B489B1B52B575A598FD@CANPRD01.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Palmer Dabbelt <palmer@sifive.com>, "logang@deltatee.com" <logang@deltatee.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "aou@eecs.berkeley.edu" <aou@eecs.berkeley.edu>, Christoph Hellwig <hch@lst.de>, Andrew Waterman <andrew@sifive.com>, Olof Johansson <olof@lixom.net>, Michael Clark <michaeljclark@mac.com>, "robh@kernel.org" <robh@kernel.org>, "zong@andestech.com" <zong@andestech.com>

UGFsbWVyDQoNCj4gSSBkb24ndCByZWFsbHkga25vdyBhbnl0aGluZyBhYm91dCB0aGlzLCBidXQg
eW91J3JlIHdlbGNvbWUgdG8gYWRkIGENCj4gICAgDQo+ICAgIFJldmlld2VkLWJ5OiBQYWxtZXIg
RGFiYmVsdCA8cGFsbWVyQHNpZml2ZS5jb20+DQoNClRoYW5rcy4gSSB0aGluayBpdCB3b3VsZCBi
ZSBnb29kIHRvIGdldCBzb21lb25lIHdobydzIGZhbWlsaWFyIHdpdGggbGludXgvbW0gdG8gdGFr
ZSBhIGxvb2suDQogICAgDQo+IGlmIHlvdSB0aGluayBpdCdsbCBoZWxwLiAgSSdtIGFzc3VtaW5n
IHlvdSdyZSB0YXJnZXRpbmcgYSBkaWZmZXJlbnQgdHJlZSBmb3IgDQo+IHRoZSBwYXRjaCBzZXQs
IGluIHdoaWNoIGNhc2UgaXQncyBwcm9iYWJseSBiZXN0IHRvIGtlZXAgdGhpcyB0b2dldGhlciB3
aXRoIHRoZSANCj4gcmVzdCBvZiBpdC4NCg0KTm8gSSB0aGluayB0aGlzIHNlcmllcyBzaG91bGQg
YmUgcHVsbGVkIGJ5IHRoZSBSSVNDLVYgbWFpbnRhaW5lci4gVGhlIG90aGVyIHBhdGNoZXMgaW4g
dGhpcyBzZXJpZXMganVzdCByZWZhY3RvciBzb21lIGNvZGUgYW5kIG5lZWQgdG8gYmUgQUNLJ2Vk
IGJ5IHRoZWlyIEFSQ0ggZGV2ZWxvcGVycyBidXQgSSBzdXNwZWN0IHRoZSBzZXJpZXMgc2hvdWxk
IGJlIHB1bGxlZCBpbnRvIFJJU0MtVi4gVGhhdCBzYWlkIHNpbmNlIGl0IGRvZXMgdG91Y2ggb3Ro
ZXIgYXJjaCBzaG91bGQgaXQgYmUgcHVsbGVkIGJ5IG1tPyANCg0KQlRXIG5vdGUgdGhhdCBSSVND
LVYgU1BBUlNFTUVNIHN1cHBvcnQgaXMgcHJldHR5IHVzZWZ1bCBmb3IgYWxsIG1hbm5lciBvZiB0
aGluZ3MgYW5kIG5vdCBqdXN0IHRoZSBwMnBkbWEgZGlzY3Vzc2VkIGluIHRoZSBjb3Zlci4NCiAg
ICANCj4gVGhhbmtzIGZvciBwb3J0aW5nIHlvdXIgc3R1ZmYgdG8gUklTQy1WIQ0KDQpZb3UgYmV0
IDstKQ0KDQpTdGVwaGVuDQogICAgDQogICAgDQoNCg==
