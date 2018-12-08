Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A14448E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 21:07:47 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id t72so4867844pfi.21
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 18:07:47 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id w32si1144195pga.337.2018.12.07.18.07.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Dec 2018 18:07:46 -0800 (PST)
From: "Huang, Kai" <kai.huang@intel.com>
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
Date: Sat, 8 Dec 2018 02:07:41 +0000
Message-ID: <1544234854.28511.60.camel@intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
	 <CALCETrUqqQiHR_LJoKB2JE6hCZ-e7LiFprEhmo-qoegDZJ9uYQ@mail.gmail.com>
	 <c610138f-32dd-a24c-dc52-4e0006a21409@intel.com>
	 <CALCETrU34U3berTaEQbvNt0rfCdsjwj+xDb8x7bgAMFHEo=eUw@mail.gmail.com>
	 <1544147742.28511.18.camel@intel.com>
	 <CALCETrWHqE-H1jTJY-ApuuLt5cyZ3N1UdgH+szgYm+7mUMZ2pg@mail.gmail.com>
In-Reply-To: <CALCETrWHqE-H1jTJY-ApuuLt5cyZ3N1UdgH+szgYm+7mUMZ2pg@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <F77482DBCC9B2E488EA73293CF91CD44@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "luto@kernel.org" <luto@kernel.org>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "jmorris@namei.org" <jmorris@namei.org>, "peterz@infradead.org" <peterz@infradead.org>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "willy@infradead.org" <willy@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "dhowells@redhat.com" <dhowells@redhat.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>, "bp@alien8.de" <bp@alien8.de>, "Hansen, Dave" <dave.hansen@intel.com>, "Schofield, Alison" <alison.schofield@intel.com>, "Nakajima, Jun" <jun.nakajima@intel.com>

DQo+ID4gVGhlcmUgYXJlIHNvbWUgb3RoZXIgdXNlIGNhc2VzIHRoYXQgYWxyZWFkeSByZXF1aXJl
IHRlbmFudCB0byBzZW5kIGtleSB0byBDU1AuIEZvciBleGFtcGxlLCB0aGUNCj4gPiBWTQ0KPiA+
IGltYWdlIGNhbiBiZSBwcm92aWRlZCBieSB0ZW5hbnQgYW5kIGVuY3J5cHRlZCBieSB0ZW5hbnQn
cyBvd24ga2V5LCBhbmQgdGVuYW50IG5lZWRzIHRvIHNlbmQga2V5DQo+ID4gdG8NCj4gPiBDU1Ag
d2hlbiBhc2tpbmcgQ1NQIHRvIHJ1biB0aGF0IGVuY3J5cHRlZCBpbWFnZS4NCj4gDQo+IA0KPiBJ
IGNhbiBpbWFnaW5lIGEgZmV3IHJlYXNvbnMgd2h5IG9uZSB3b3VsZCB3YW50IHRvIGVuY3J5cHQg
b25l4oCZcyBpbWFnZS4NCj4gRm9yIGV4YW1wbGUsIHRoZSBDU1AgY291bGQgaXNzdWUgYSBwdWJs
aWMga2V5IGFuZCBzdGF0ZSwgb3IgZXZlbg0KPiBhdHRlc3QsIHRoYXQgdGhlIGtleSBpcyB3cmFw
cGVkIGFuZCBsb2NrZWQgdG8gcGFydGljdWxhciBQQ1JzIG9mIHRoZWlyDQo+IFRQTSBvciBvdGhl
cndpc2UgcHJvdGVjdGVkIGJ5IGFuIGVuY2xhdmUgdGhhdCB2ZXJpZmllcyB0aGF0IHRoZSBrZXkg
aXMNCj4gb25seSB1c2VkIHRvIGRlY3J5cHQgdGhlIGltYWdlIGZvciB0aGUgYmVuZWZpdCBvZiBh
IGh5cGVydmlzb3IuDQoNClJpZ2h0LiBJIHRoaW5rIGJlZm9yZSB0ZW5hbnQgcmVsZWFzZXMga2V5
IHRvIENTUCBpdCBzaG91bGQgYWx3YXlzIHVzZSBhdHRlc3RhdGlvbiBhdXRob3JpdHkgdG8NCnZl
cmlmeSB0aGUgdHJ1c3RpbmVzcyBvZiBjb21wdXRlciBub2RlLiBJIGNhbiB1bmRlcnN0YW5kIHRo
YXQgdGhlIGtleSBjYW4gYmUgd3JhcHBlZCBieSBUUE0gYmVmb3JlDQpzZW5kaW5nIHRvIENTUCBi
dXQgbmVlZCBzb21lIGNhdGNoIHVwIGFib3V0IHVzaW5nIGVuY2xhdmUgcGFydC4gDQoNClRoZSB0
aGluZyBpcyBjb21wdXRlciBub2RlIGNhbiBiZSB0cnVzdGVkIGRvZXNuJ3QgbWVhbiBpdCBjYW5u
b3QgYmUgYXR0YWNrZWQsIG9yIGV2ZW4gaXQgZG9lc24ndA0KbWVhbiBpdCBjYW4gcHJldmVudCwg
aWUgc29tZSBtYWxpY2lvdXMgYWRtaW4sIHRvIGdldCB0ZW5hbnQga2V5IGV2ZW4gYnkgdXNpbmcg
bGVnaXRpbWF0ZSB3YXkuIFRoZXJlDQphcmUgbWFueSBTVyBjb21wb25lbnRzIGludm9sdmVkIGhl
cmUuIEFueXdheSB0aGlzIGlzIG5vdCByZWxhdGVkIHRvIE1LVE1FIGl0c2VsZiBsaWtlIHlvdSBt
ZW50aW9uZWQNCmJlbG93LCB0aGVyZWZvcmUgdGhlIHBvaW50IGlzLCBhcyB3ZSBhbHJlYWR5IHNl
ZSBNS1RNRSBpdHNlbGYgcHJvdmlkZXMgdmVyeSB3ZWFrIHNlY3VyaXR5DQpwcm90ZWN0aW9uLCB3
ZSBuZWVkIHRvIHNlZSB3aGV0aGVyIE1LVE1FIGhhcyB2YWx1ZSBmcm9tIHRoZSB3aG9sZSB1c2Ug
Y2FzZSdzIHBvaW50IG9mIHZpZXcNCihpbmNsdWRpbmcgYWxsIHRoZSB0aGluZ3MgeW91IG1lbnRp
b25lZCBhYm92ZSkgLS0gd2UgZGVmaW5lIHRoZSB3aG9sZSB1c2UgY2FzZSwgd2UgY2xlYXJseSBz
dGF0ZQ0Kd2hvL3doYXQgc2hvdWxkIGJlIGluIHRydXN0IGJvdW5kYXJ5LCBhbmQgd2hhdCB3ZSBj
YW4gcHJldmVudCwgZXRjLg0KDQo+IA0KPiBJIGRvbuKAmXQgc2VlIHdoYXQgTUtUTUUgaGFzIHRv
IGRvIHdpdGggdGhpcy4gVGhlIG9ubHkgcmVtb3RlbHkNCj4gcGxhdXNpYmxlIHdheSBJIGNhbiBz
ZWUgdG8gdXNlIE1LVE1FIGZvciB0aGlzIGlzIHRvIGhhdmUgdGhlDQo+IGh5cGVydmlzb3IgbG9h
ZCBhIFRQTSAob3Igb3RoZXIgZW5jbGF2ZSkgcHJvdGVjdGVkIGtleSBpbnRvIGFuIE1LVE1FDQo+
IHVzZXIga2V5IHNsb3QgYW5kIHRvIGxvYWQgY3VzdG9tZXItcHJvdmlkZWQgY2lwaGVydGV4dCBp
bnRvIHRoZQ0KPiBjb3JyZXNwb25kaW5nIHBoeXNpY2FsIG1lbW9yeSAodXNpbmcgYW4gTUtUTUUg
bm8tZW5jcnlwdCBzbG90KS4gIEJ1dA0KPiB0aGlzIGhhcyB0aHJlZSBtYWpvciBwcm9ibGVtcy4g
IEZpcnN0LCBpdCdzIGVmZmVjdGl2ZWx5IGp1c3QgYSBmYW5jeQ0KPiB3YXkgdG8gYXZvaWQgb25l
IEFFUyBwYXNzIG92ZXIgdGhlIGRhdGEuICBTZWNvbmQsIHNlbnNpYmxlIHNjaGVtZSBmb3INCj4g
dGhpcyB0eXBlIG9mIFZNIGltYWdlIHByb3RlY3Rpb24gd291bGQgdXNlICphdXRoZW50aWNhdGVk
KiBlbmNyeXB0aW9uDQo+IG9yIGF0IGxlYXN0IHZlcmlmeSBhIHNpZ25hdHVyZSwgd2hpY2ggTUtU
TUUgY2FuJ3QgZG8uICBUaGUgdGhpcmQNCj4gcHJvYmxlbSBpcyB0aGUgcmVhbCBzaG93LXN0b3Bw
ZXIsIHRob3VnaDogdGhpcyBzY2hlbWUgcmVxdWlyZXMgdGhhdA0KPiB0aGUgY2lwaGVydGV4dCBn
byBpbnRvIHByZWRldGVybWluZWQgcGh5c2ljYWwgYWRkcmVzc2VzLCB3aGljaCB3b3VsZA0KPiBi
ZSBhIGdpYW50IG1lc3MuDQoNCk15IGludGVudGlvbiB3YXMgdG8gc2F5IGlmIHdlIGFyZSBhbHJl
YWR5IHNlbmRpbmcga2V5IHRvIENTUCwgdGhlbiB3ZSBtYXkgcHJlZmVyIHRvIHVzZSB0aGUga2V5
IGZvcg0KTUtUTUUgVk0gcnVudGltZSBwcm90ZWN0aW9uIGFzIHdlbGwsIGJ1dCBsaWtlIHlvdSBz
YWlkIHdlIG1heSBub3QgaGF2ZSByZWFsIHNlY3VyaXR5IGdhaW4gaGVyZQ0KY29tcGFyaW5nIHRv
IFRNRSwgc28gSSBhZ3JlZSB3ZSBuZWVkIHRvIGZpbmQgb3V0IG9uZSBzcGVjaWZpYyBjYXNlIHRv
IHByb3ZlIHRoYXQuDQoNClRoYW5rcywNCi1LYWk=
