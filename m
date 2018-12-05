Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 21D156B7630
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 15:30:21 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id i3so17740841pfj.4
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 12:30:21 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id w8si19321931pgm.467.2018.12.05.12.30.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 12:30:20 -0800 (PST)
From: "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
Date: Wed, 5 Dec 2018 20:30:15 +0000
Message-ID: <b7fa2f2337adadd24594d7e799c337a9c7eaf906.camel@intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
In-Reply-To: <cover.1543903910.git.alison.schofield@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <3A8A9C5F0E0B8C4FB8F40BC9179B80DA@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "tglx@linutronix.de" <tglx@linutronix.de>, "Schofield, Alison" <alison.schofield@intel.com>, "dhowells@redhat.com" <dhowells@redhat.com>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "peterz@infradead.org" <peterz@infradead.org>, "jmorris@namei.org" <jmorris@namei.org>, "Huang, Kai" <kai.huang@intel.com>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "bp@alien8.de" <bp@alien8.de>, Hansen,, Jun

T24gTW9uLCAyMDE4LTEyLTAzIGF0IDIzOjM5IC0wODAwLCBBbGlzb24gU2Nob2ZpZWxkIHdyb3Rl
Og0KPiBIaSBUaG9tYXMsIERhdmlkLA0KPiANCj4gSGVyZSBpcyBhbiB1cGRhdGVkIFJGQyBvbiB0
aGUgQVBJJ3MgdG8gc3VwcG9ydCBNS1RNRS4NCj4gKE11bHRpLUtleSBUb3RhbCBNZW1vcnkgRW5j
cnlwdGlvbikNCj4gDQo+IFRoaXMgUkZDIHByZXNlbnRzIHRoZSAyIEFQSSBhZGRpdGlvbnMgdG8g
c3VwcG9ydCB0aGUgY3JlYXRpb24gYW5kDQo+IHVzYWdlIG9mIG1lbW9yeSBlbmNyeXB0aW9uIGtl
eXM6DQo+ICAxKSBLZXJuZWwgS2V5IFNlcnZpY2UgdHlwZSAibWt0bWUiDQo+ICAyKSBTeXN0ZW0g
Y2FsbCBlbmNyeXB0X21wcm90ZWN0KCkNCj4gDQo+IFRoaXMgcGF0Y2hzZXQgaXMgYnVpbHQgdXBv
biBLaXJpbGwgU2h1dGVtb3YncyB3b3JrIGZvciB0aGUgY29yZSBNS1RNRQ0KPiBzdXBwb3J0Lg0K
DQpQbGVhc2UsIGV4cGxhaW4gd2hhdCBNS1RNRSBpcyByaWdodCBoZXJlLg0KDQpObyByZWZlcmVu
Y2VzLCBubyBleHBsYW5hdGlvbnMuLi4gRXZlbiB3aXRoIGEgcmVmZXJlbmNlLCBhIHNob3J0DQpz
dW1tYXJ5IHdvdWxkIGJlIHJlYWxseSBuaWNlIHRvIGhhdmUuDQoNCi9KYXJra28NCg==
