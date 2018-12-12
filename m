Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id DE09E8E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 18:24:25 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id t2so121117pfj.15
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 15:24:25 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id ba9si127086plb.109.2018.12.12.15.24.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 15:24:24 -0800 (PST)
From: "Huang, Kai" <kai.huang@intel.com>
Subject: RE: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
Date: Wed, 12 Dec 2018 23:24:17 +0000
Message-ID: <105F7BF4D0229846AF094488D65A0989355536E9@PGSMSX112.gar.corp.intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
 <CALCETrUqqQiHR_LJoKB2JE6hCZ-e7LiFprEhmo-qoegDZJ9uYQ@mail.gmail.com>
 <0a21eadd05b245f762f7d536d8fdf579c113a9bc.camel@intel.com>
 <20181207115713.ia5jbrx5e3osaqxi@kshutemo-mobl1>
 <fd94ec722edc45008097a39d0c84a5d7134641c7.camel@intel.com>
 <19c539f8c6c9b34974e4cb4f268eb64fe7ba4297.camel@intel.com>
 <655394650664715c39ef242689fbc8af726f09c3.camel@intel.com>
 <CALCETrVztbuRUnp9MUz-Pp85NhY2htNZHGszS+mU_oWoXK3u6A@mail.gmail.com>
In-Reply-To: <CALCETrVztbuRUnp9MUz-Pp85NhY2htNZHGszS+mU_oWoXK3u6A@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, James Morris <jmorris@namei.org>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, "Thomas Gleixner  <tglx@linutronix.de>, Linux-MM <linux-mm@kvack.org>, David Howells" <dhowells@redhat.com>, LSM List <linux-security-module@vger.kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, X86 ML <x86@kernel.org>, "H. Peter Anvin  <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov" <bp@alien8.de>, "Hansen, Dave" <dave.hansen@intel.com>, "Schofield, Alison" <alison.schofield@intel.com>, "Nakajima, Jun" <jun.nakajima@intel.com>

PiBJIHN0cm9uZ2x5IHN1c3BlY3QgdGhhdCwgb24gTDFURi12dWxuZXJhYmxlIENQVXMsIE1LVE1F
IHByb3ZpZGVzIG5vDQo+IHByb3RlY3Rpb24gd2hhdHNvZXZlci4gIEl0IHNvdW5kcyBsaWtlIE1L
VE1FIGlzIGltcGxlbWVudGVkIGluIHRoZQ0KPiBtZW1vcnkgY29udHJvbGxlciAtLSBhcyBmYXIg
YXMgdGhlIHJlc3Qgb2YgdGhlIENQVSBhbmQgdGhlIGNhY2hlIGhpZXJhcmNoeQ0KPiBhcmUgY29u
Y2VybmVkLCB0aGUgTUtUTUUga2V5IHNlbGN0aW9uIGJpdHMgYXJlIGp1c3QgcGFydCBvZiB0aGUg
cGh5c2ljYWwNCj4gYWRkcmVzcy4gIFNvIGFuIGF0dGFjayBsaWtlIEwxVEYgdGhhdCBsZWFrcyBh
IGNhY2hlbGluZSB0aGF0J3Mgc2VsZWN0ZWQgYnkNCj4gcGh5c2ljYWwgYWRkcmVzcyB3aWxsIGxl
YWsgdGhlIGNsZWFydGV4dCBpZiB0aGUga2V5IHNlbGVjdGlvbiBiaXRzIGFyZSBzZXQNCj4gY29y
cmVjdGx5Lg0KDQpSaWdodC4gTUtUTUUgZG9lc24ndCBwcmV2ZW50IGNhY2hlIGJhc2VkIGF0dGFj
ay4gRGF0YSBpbiBjYWNoZSBpcyBpbiBjbGVhci4NCg0KVGhhbmtzLA0KLUthaQ0KDQo=
