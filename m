Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id DEE7A8E0161
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 00:52:17 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id u20so841576pfa.1
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 21:52:17 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id r6si818170pli.248.2018.12.12.21.52.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 21:52:16 -0800 (PST)
From: "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
Date: Thu, 13 Dec 2018 05:52:12 +0000
Message-ID: <d33cc487ebce596056096e3db46ee1ae0e9d7da6.camel@intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
	 <CALCETrUqqQiHR_LJoKB2JE6hCZ-e7LiFprEhmo-qoegDZJ9uYQ@mail.gmail.com>
	 <0a21eadd05b245f762f7d536d8fdf579c113a9bc.camel@intel.com>
	 <20181207115713.ia5jbrx5e3osaqxi@kshutemo-mobl1>
	 <fd94ec722edc45008097a39d0c84a5d7134641c7.camel@intel.com>
	 <19c539f8c6c9b34974e4cb4f268eb64fe7ba4297.camel@intel.com>
	 <655394650664715c39ef242689fbc8af726f09c3.camel@intel.com>
	 <CALCETrVztbuRUnp9MUz-Pp85NhY2htNZHGszS+mU_oWoXK3u6A@mail.gmail.com>
	 <42cb695e947e2c98a989285778d56a241fe67e7f.camel@intel.com>
	 <105F7BF4D0229846AF094488D65A098935553717@PGSMSX112.gar.corp.intel.com>
	 <191aa6bc11ec795d0108f3369c3f696cd8a43171.camel@intel.com>
In-Reply-To: <191aa6bc11ec795d0108f3369c3f696cd8a43171.camel@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <052226B093F4784DAFBA4B413CF0511F@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Kai" <kai.huang@intel.com>, "luto@kernel.org" <luto@kernel.org>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "peterz@infradead.org" <peterz@infradead.org>, "jmorris@namei.org" <jmorris@namei.org>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "willy@infradead.org" <willy@infradead.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dhowells@redhat.com" <dhowells@redhat.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "kirill@shutemov.name" <kirill@shutemov.name>, "bp@alien8.de" <bp@alien8.de>, "Hansen, Dave" <dave.hansen@intel.com>, "Schofield, Alison" <alison.schofield@intel.com>, "Nakajima, Jun" <jun.nakajima@intel.com>

T24gVGh1LCAyMDE4LTEyLTEzIGF0IDA3OjQ5ICswMjAwLCBKYXJra28gU2Fra2luZW4gd3JvdGU6
DQo+IE9uIFRodSwgMjAxOC0xMi0xMyBhdCAwNzoyNyArMDgwMCwgSHVhbmcsIEthaSB3cm90ZToN
Cj4gPiA+IFRoaXMgYWxsIHNob3VsZCBiZSBzdW1tYXJpemVkIGluIHRoZSBkb2N1bWVudGF0aW9u
IChoaWdoLWxldmVsIG1vZGVsIGFuZA0KPiA+ID4gY29ybmVyIGNhc2VzKS4NCj4gPiANCj4gPiBJ
IGFtIG5vdCBzdXJlIHdoZXRoZXIgaXQgaXMgbmVjZXNzYXJ5IHRvIGRvY3VtZW50IEwxVEYgZXhw
bGljaXRseSwgc2luY2UgaXQNCj4gPiBpcw0KPiA+IHF1aXRlIG9idmlvdXMgdGhhdCBNS1RNRSBk
b2Vzbid0IHByZXZlbnQgdGhhdC4gSU1ITyBpZiBuZWVkZWQgd2Ugb25seSBuZWVkDQo+ID4gdG8N
Cj4gPiBtZW50aW9uIE1LVE1FIGRvZXNuJ3QgcHJldmVudCBhbnkgc29ydCBvZiBjYWNoZSBiYXNl
ZCBhdHRhY2ssIHNpbmNlIGRhdGEgaW4NCj4gPiBjYWNoZSBpcyBpbiBjbGVhci4NCj4gPiANCj4g
PiBJbiBmYWN0IFNHWCBkb2Vzbid0IHByZXZlbnQgdGhpcyBlaXRoZXIuLg0KPiANCj4gU29ycnks
IHdhcyBhIGJpdCB1bmNsZWFyLiBJIG1lYW50IHRoZSBhc3N1bXB0aW9ucyBhbmQgZ29hbHMuDQoN
CkkuZS4gd2hhdCBJIHB1dCBpbiBteSBlYXJsaWVyIHJlc3BvbnNlLCB3aGF0IGJlbG9uZ3MgdG8g
VENCIGFuZCB3aGF0DQp0eXBlcyBhZHZlcnNhcmllcyBpcyBwdXJzdWVkIHRvIGJlIHByb3RlY3Rl
ZC4NCg0KL0phcmtrbw0K
