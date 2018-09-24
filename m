Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id DD0A08E0041
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 17:28:05 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id v186-v6so7265030pgb.14
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 14:28:05 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id j16-v6si402754pgg.350.2018.09.24.14.28.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Sep 2018 14:28:04 -0700 (PDT)
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Subject: Re: [PATCH v6 2/4] x86/modules: Increase randomization for modules
Date: Mon, 24 Sep 2018 21:27:59 +0000
Message-ID: <1537824509.19013.63.camel@intel.com>
References: <1536874298-23492-1-git-send-email-rick.p.edgecombe@intel.com>
	 <1536874298-23492-3-git-send-email-rick.p.edgecombe@intel.com>
	 <CAGXu5jJ9nZYbVn5xdi7nsMJRD6ScLeWP2DWjrD8yEfwi-XXcRw@mail.gmail.com>
	 <1537815484.19013.48.camel@intel.com>
	 <CAGXu5jKho6Ui0sP6-4FN=i6zZ1+gXcd9Zyctqhvg+4r1cz-Mqw@mail.gmail.com>
In-Reply-To: <CAGXu5jKho6Ui0sP6-4FN=i6zZ1+gXcd9Zyctqhvg+4r1cz-Mqw@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <FD2C558B1FC37546962D0EAC9E8E4E4F@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "keescook@chromium.org" <keescook@chromium.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "daniel@iogearbox.net" <daniel@iogearbox.net>, "arjan@linux.intel.com" <arjan@linux.intel.com>, "jannh@google.com" <jannh@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Hansen, Dave" <dave.hansen@intel.com>

T24gTW9uLCAyMDE4LTA5LTI0IGF0IDEyOjU4IC0wNzAwLCBLZWVzIENvb2sgd3JvdGU6DQo+IE9u
IE1vbiwgU2VwIDI0LCAyMDE4IGF0IDExOjU3IEFNLCBFZGdlY29tYmUsIFJpY2sgUA0KPiA8cmlj
ay5wLmVkZ2Vjb21iZUBpbnRlbC5jb20+IHdyb3RlOg0KPiA+ID4gSW5zdGVhZCBvZiBoYXZpbmcg
dHdvIG9wZW4tY29kZWQgX192bWFsbG9jX25vZGVfcmFuZ2UoKSBjYWxscyBsZWZ0IGluDQo+ID4g
PiB0aGlzIGFmdGVyIHRoZSBjaGFuZ2UsIGNhbiB0aGlzIGJlIGRvbmUgaW4gdGVybXMgb2YgYSBj
YWxsIHRvDQo+ID4gPiB0cnlfbW9kdWxlX2FsbG9jKCkgaW5zdGVhZD8gSSBzZWUgdGhleSdyZSBz
bGlnaHRseSBkaWZmZXJlbnQsIGJ1dCBpdA0KPiA+ID4gbWlnaHQgYmUgbmljZSBmb3IgbWFraW5n
IHRoZSB0d28gcGF0aHMgc2hhcmUgbW9yZSBjb2RlLg0KPiA+IE5vdCBzdXJlIHdoYXQgeW91IG1l
YW4uIEFjcm9zcyB0aGUgd2hvbGUgY2hhbmdlLCB0aGVyZSBpcyBvbmUgY2FsbA0KPiA+IHRvIF9f
dm1hbGxvY19ub2RlX3JhbmdlLCBhbmQgb25lIHRvIF9fdm1hbGxvY19ub2RlX3RyeV9hZGRyLg0K
PiBJIGd1ZXNzIEkgbWVhbnQgdGhlIHZtYWxsb2MgY2FsbHMgLS0gb25lIGZvciBub2RlX3Jhbmdl
IGFuZCBvbmUgZm9yDQo+IG5vZGVfdHJ5X2FkZHIuIEkgd2FzIHdvbmRlcmluZyBpZiB0aGUgbG9n
aWMgY291bGQgYmUgY29tYmluZWQgaW4gc29tZQ0KPiB3YXkgc28gdGhhdCB0aGUgX192bWFsbG9j
X25vZGVfcmFuZ2UoKSBjb3VsZCBiZSBtYWRlIGluIHRlcm1zIG9mIHRoZQ0KPiB0aGUgaGVscGVy
IHRoYXQgdHJ5X21vZHVsZV9yYW5kb21pemVfZWFjaCgpIHVzZXMuIEJ1dCB0aGlzIGNvdWxkIGp1
c3QNCj4gYmUgbWUgaG9waW5nIGZvciBuaWNlLXRvLXJlYWQgY2hhbmdlcy4gOykNCj4gDQo+IC1L
ZWVzDQpPbmUgdGhpbmcgSSBoYWQgYmVlbiBjb25zaWRlcmluZyB3YXMgdG8gbW92ZSB0aGUgd2hv
bGUgInRyeSByYW5kb20gbG9jYXRpb25zLA0KdGhlbiB1c2UgYmFja3VwIiBsb2dpYyB0byB2bWFs
bG9jLmMsIGFuZCBqdXN0IGhhdmUgcGFyYW1ldGVycyBmb3IgcmFuZG9tIGFyZWENCnNpemUsIG51
bWJlciBvZiB0cmllcywgZXRjLiBUaGlzIHdheSBpdCBjb3VsZCBiZSBwb3NzaWJseSBiZSByZS11
c2VkIGZvciBvdGhlcg0KYXJjaGl0ZWN0dXJlcyBmb3IgbW9kdWxlcy4gQWxzbyBvbiBvdXIgbGlz
dCBpcyB0byBsb29rIGF0IHJhbmRvbWl6aW5nIHZtYWxsb2MNCnNwYWNlIChlc3BlY2lhbGx5IHN0
YWNrcyksIHdoaWNoIG1heSBvciBtYXkgbm90IGludm9sdmUgdXNpbmcgYSBzaW1pbGFyIG1ldGhv
ZC4NCg0KU28gbWF5YmUgYml0IHByZS1tYXR1cmUgcmVmYWN0b3JpbmcsIGJ1dCB3b3VsZCBhbHNv
IGNsZWFuIHVwIHRoZSBjb2RlIGluDQptb2R1bGUuYy4gRG8geW91IHRoaW5rIGl0IHdvdWxkIGJl
IHdvcnRoIGl0Pw0KDQpUaGFua3MsDQoNClJpY2s=
