Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 447128E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 18:27:40 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id h10so108510plk.12
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 15:27:40 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id v5si141756pgg.1.2018.12.12.15.27.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 15:27:39 -0800 (PST)
From: "Huang, Kai" <kai.huang@intel.com>
Subject: RE: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
Date: Wed, 12 Dec 2018 23:27:33 +0000
Message-ID: <105F7BF4D0229846AF094488D65A098935553717@PGSMSX112.gar.corp.intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
	 <CALCETrUqqQiHR_LJoKB2JE6hCZ-e7LiFprEhmo-qoegDZJ9uYQ@mail.gmail.com>
	 <0a21eadd05b245f762f7d536d8fdf579c113a9bc.camel@intel.com>
	 <20181207115713.ia5jbrx5e3osaqxi@kshutemo-mobl1>
	 <fd94ec722edc45008097a39d0c84a5d7134641c7.camel@intel.com>
	 <19c539f8c6c9b34974e4cb4f268eb64fe7ba4297.camel@intel.com>
	 <655394650664715c39ef242689fbc8af726f09c3.camel@intel.com>
	 <CALCETrVztbuRUnp9MUz-Pp85NhY2htNZHGszS+mU_oWoXK3u6A@mail.gmail.com>
 <42cb695e947e2c98a989285778d56a241fe67e7f.camel@intel.com>
In-Reply-To: <42cb695e947e2c98a989285778d56a241fe67e7f.camel@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>, "luto@kernel.org" <luto@kernel.org>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "peterz@infradead.org" <peterz@infradead.org>, "jmorris@namei.org" <jmorris@namei.org>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "willy@infradead.org" <willy@infradead.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dhowells@redhat.com" <dhowells@redhat.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "kirill@shutemov.name" <kirill@shutemov.name>, "bp@alien8.de" <bp@alien8.de>, "Hansen, Dave" <dave.hansen@intel.com>, "Schofield, Alison" <alison.schofield@intel.com>, "Nakajima, Jun" <jun.nakajima@intel.com>

PiBUaGlzIGFsbCBzaG91bGQgYmUgc3VtbWFyaXplZCBpbiB0aGUgZG9jdW1lbnRhdGlvbiAoaGln
aC1sZXZlbCBtb2RlbCBhbmQNCj4gY29ybmVyIGNhc2VzKS4NCg0KSSBhbSBub3Qgc3VyZSB3aGV0
aGVyIGl0IGlzIG5lY2Vzc2FyeSB0byBkb2N1bWVudCBMMVRGIGV4cGxpY2l0bHksIHNpbmNlIGl0
IGlzIHF1aXRlIG9idmlvdXMgdGhhdCBNS1RNRSBkb2Vzbid0IHByZXZlbnQgdGhhdC4gSU1ITyBp
ZiBuZWVkZWQgd2Ugb25seSBuZWVkIHRvIG1lbnRpb24gTUtUTUUgZG9lc24ndCBwcmV2ZW50IGFu
eSBzb3J0IG9mIGNhY2hlIGJhc2VkIGF0dGFjaywgc2luY2UgZGF0YSBpbiBjYWNoZSBpcyBpbiBj
bGVhci4NCg0KSW4gZmFjdCBTR1ggZG9lc24ndCBwcmV2ZW50IHRoaXMgZWl0aGVyLi4NCg0KVGhh
bmtzLA0KLUthaQ0K
