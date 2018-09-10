Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id D0BAC8E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 14:22:03 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 191-v6so10972700pgb.23
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 11:22:03 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id x1-v6si17921951plb.135.2018.09.10.11.22.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 11:22:02 -0700 (PDT)
From: "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>
Subject: Re: [RFC 09/12] mm: Restrict memory encryption to anonymous VMA's
Date: Mon, 10 Sep 2018 18:21:58 +0000
Message-ID: <ae0288d5205a5c431e9a6bf0c9e68beded45e84b.camel@intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
	 <f69e3d4f96504185054d951c7c85075ebf63e47a.1536356108.git.alison.schofield@intel.com>
In-Reply-To: <f69e3d4f96504185054d951c7c85075ebf63e47a.1536356108.git.alison.schofield@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <67A9E709063A53478BBE67F4AD6CB769@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "tglx@linutronix.de" <tglx@linutronix.de>, "Schofield, Alison" <alison.schofield@intel.com>, "dhowells@redhat.com" <dhowells@redhat.com>
Cc: "Shutemov, Kirill" <kirill.shutemov@intel.com>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "jmorris@namei.org" <jmorris@namei.org>, "Huang,
 Kai" <kai.huang@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "Nakajima, Jun" <jun.nakajima@intel.com>

T24gRnJpLCAyMDE4LTA5LTA3IGF0IDE1OjM3IC0wNzAwLCBBbGlzb24gU2Nob2ZpZWxkIHdyb3Rl
Og0KPiBNZW1vcnkgZW5jcnlwdGlvbiBpcyBvbmx5IHN1cHBvcnRlZCBmb3IgbWFwcGluZ3MgdGhh
dCBhcmUgQU5PTllNT1VTLg0KPiBUZXN0IHRoZSBlbnRpcmUgcmFuZ2Ugb2YgVk1BJ3MgaW4gYW4g
ZW5jcnlwdF9tcHJvdGVjdCgpIHJlcXVlc3QgdG8NCj4gbWFrZSBzdXJlIHRoZXkgYWxsIG1lZXQg
dGhhdCByZXF1aXJlbWVudCBiZWZvcmUgZW5jcnlwdGluZyBhbnkuDQo+IA0KPiBUaGUgZW5jcnlw
dF9tcHJvdGVjdCBzeXNjYWxsIHdpbGwgcmV0dXJuIC1FSU5WQUwgYW5kIHdpbGwgbm90IGVuY3J5
cHQNCj4gYW55IFZNQSdzIGlmIHRoaXMgY2hlY2sgZmFpbHMuDQo+IA0KPiBTaWduZWQtb2ZmLWJ5
OiBBbGlzb24gU2Nob2ZpZWxkIDxhbGlzb24uc2Nob2ZpZWxkQGludGVsLmNvbT4NCj4gLS0tDQo+
ICBtbS9tcHJvdGVjdC5jIHwgMjIgKysrKysrKysrKysrKysrKysrKysrKw0KPiAgMSBmaWxlIGNo
YW5nZWQsIDIyIGluc2VydGlvbnMoKykNCj4gDQo+IGRpZmYgLS1naXQgYS9tbS9tcHJvdGVjdC5j
IGIvbW0vbXByb3RlY3QuYw0KPiBpbmRleCA2YzJlMTEwNjUyNWMuLjMzODRiNzU1YWFkMSAxMDA2
NDQNCj4gLS0tIGEvbW0vbXByb3RlY3QuYw0KPiArKysgYi9tbS9tcHJvdGVjdC5jDQo+IEBAIC0z
MTEsNiArMzExLDI0IEBAIHVuc2lnbmVkIGxvbmcgY2hhbmdlX3Byb3RlY3Rpb24oc3RydWN0IHZt
X2FyZWFfc3RydWN0DQo+ICp2bWEsIHVuc2lnbmVkIGxvbmcgc3RhcnQsDQo+ICAJcmV0dXJuIHBh
Z2VzOw0KPiAgfQ0KPiAgDQo+ICsvKg0KPiArICogRW5jcnlwdGVkIG1wcm90ZWN0IGlzIG9ubHkg
c3VwcG9ydGVkIG9uIGFub255bW91cyBtYXBwaW5ncy4NCj4gKyAqIEFsbCBWTUEncyBpbiB0aGUg
cmVxdWVzdGVkIHJhbmdlIG11c3QgYmUgYW5vbnltb3VzLiBJZiB0aGlzDQo+ICsgKiB0ZXN0IGZh
aWxzIG9uIGFueSBzaW5nbGUgVk1BLCB0aGUgZW50aXJlIG1wcm90ZWN0IHJlcXVlc3QgZmFpbHMu
DQo+ICsgKi8NCg0Ka2RvYw0KDQo+ICtib29sIG1lbV9zdXBwb3J0c19lbmNyeXB0aW9uKHN0cnVj
dCB2bV9hcmVhX3N0cnVjdCAqdm1hLCB1bnNpZ25lZCBsb25nIGVuZCkNCj4gK3sNCj4gKwlzdHJ1
Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnRlc3Rfdm1hID0gdm1hOw0KPiArDQo+ICsJZG8gew0KPiArCQlp
ZiAoIXZtYV9pc19hbm9ueW1vdXModGVzdF92bWEpKQ0KPiArCQkJcmV0dXJuIGZhbHNlOw0KPiAr
DQo+ICsJCXRlc3Rfdm1hID0gdGVzdF92bWEtPnZtX25leHQ7DQo+ICsJfSB3aGlsZSAodGVzdF92
bWEgJiYgdGVzdF92bWEtPnZtX3N0YXJ0IDwgZW5kKTsNCj4gKwlyZXR1cm4gdHJ1ZTsNCj4gK30N
Cj4gKw0KPiAgaW50DQo+ICBtcHJvdGVjdF9maXh1cChzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnZt
YSwgc3RydWN0IHZtX2FyZWFfc3RydWN0ICoqcHByZXYsDQo+ICAJICAgICAgIHVuc2lnbmVkIGxv
bmcgc3RhcnQsIHVuc2lnbmVkIGxvbmcgZW5kLCB1bnNpZ25lZCBsb25nDQo+IG5ld2ZsYWdzLA0K
PiBAQCAtNDkxLDYgKzUwOSwxMCBAQCBzdGF0aWMgaW50IGRvX21wcm90ZWN0X2V4dCh1bnNpZ25l
ZCBsb25nIHN0YXJ0LCBzaXplX3QNCj4gbGVuLA0KPiAgCQkJCWdvdG8gb3V0Ow0KPiAgCQl9DQo+
ICAJfQ0KPiArCWlmIChrZXlpZCA+IDAgJiYgIW1lbV9zdXBwb3J0c19lbmNyeXB0aW9uKHZtYSwg
ZW5kKSkgew0KPiArCQllcnJvciA9IC1FSU5WQUw7DQo+ICsJCWdvdG8gb3V0Ow0KPiArCX0NCj4g
IAlpZiAoc3RhcnQgPiB2bWEtPnZtX3N0YXJ0KQ0KPiAgCQlwcmV2ID0gdm1hOw0KPiAgDQoNCi9K
YXJra28=
