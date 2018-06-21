Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C44546B0005
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 14:56:22 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id j10-v6so1605333pgv.6
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 11:56:22 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id d184-v6si4486816pgc.577.2018.06.21.11.56.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jun 2018 11:56:21 -0700 (PDT)
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Subject: Re: [PATCH 3/3] vmalloc: Add debugfs modfraginfo
Date: Thu, 21 Jun 2018 18:56:18 +0000
Message-ID: <1529607394.29548.199.camel@intel.com>
References: <1529532570-21765-1-git-send-email-rick.p.edgecombe@intel.com>
	 <1529532570-21765-4-git-send-email-rick.p.edgecombe@intel.com>
	 <CAG48ez1QbKgoBCb-M=L+M5DJHj0URhNvS34h+Ax6RudckgCEEA@mail.gmail.com>
In-Reply-To: <CAG48ez1QbKgoBCb-M=L+M5DJHj0URhNvS34h+Ax6RudckgCEEA@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <176C2E2898EA79478B62E2CBA2A27909@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "jannh@google.com" <jannh@google.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Van De
 Ven, Arjan" <arjan.van.de.ven@intel.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "Accardi, Kristen C" <kristen.c.accardi@intel.com>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Hansen, Dave" <dave.hansen@intel.com>

T24gVGh1LCAyMDE4LTA2LTIxIGF0IDE0OjMyICswMjAwLCBKYW5uIEhvcm4gd3JvdGU6DQo+IE9u
IFRodSwgSnVuIDIxLCAyMDE4IGF0IDEyOjEyIEFNIFJpY2sgRWRnZWNvbWJlDQo+IDxyaWNrLnAu
ZWRnZWNvbWJlQGludGVsLmNvbT4gd3JvdGU6DQo+ID4gDQo+ID4gQWRkIGRlYnVnZnMgZmlsZSAi
bW9kZnJhZ2luZm8iIGZvciBwcm92aWRpbmcgaW5mbyBvbiBtb2R1bGUgc3BhY2UNCj4gPiBmcmFn
bWVudGF0aW9uLsKgwqBUaGlzIGNhbiBiZSB1c2VkIGZvciBkZXRlcm1pbmluZyBpZiBsb2FkYWJs
ZSBtb2R1bGUNCj4gPiByYW5kb21pemF0aW9uIGlzIGNhdXNpbmcgYW55IHByb2JsZW1zIGZvciBl
eHRyZW1lIG1vZHVsZSBsb2FkaW5nDQo+ID4gc2l0dWF0aW9ucywNCj4gPiBsaWtlIGh1Z2UgbnVt
YmVycyBvZiBtb2R1bGVzIG9yIGV4dHJlbWVseSBsYXJnZSBtb2R1bGVzLg0KPiA+IA0KPiA+IFNh
bXBsZSBvdXRwdXQgd2hlbiBSQU5ET01JWkVfQkFTRSBhbmQgWDg2XzY0IGlzIGNvbmZpZ3VyZWQ6
DQo+ID4gTGFyZ2VzdCBmcmVlIHNwYWNlOsKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgODQ3MjUz
NTA0DQo+ID4gRXh0ZXJuYWwgTWVtb3J5IEZyYWdlbWVudGF0aW9uOiAyMCUNCj4gPiBBbGxvY2F0
aW9ucyBpbiBiYWNrdXAgYXJlYTrCoMKgwqDCoMKgMA0KPiA+IA0KPiA+IFNhbXBsZSBvdXRwdXQg
b3RoZXJ3aXNlOg0KPiA+IExhcmdlc3QgZnJlZSBzcGFjZTrCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoDg0NzI1MzUwNA0KPiA+IEV4dGVybmFsIE1lbW9yeSBGcmFnZW1lbnRhdGlvbjogMjAlDQo+
IFsuLi5dDQo+ID4gDQo+ID4gK8KgwqDCoMKgwqDCoMKgc2VxX3ByaW50ZihtLCAiTGFyZ2VzdCBm
cmVlIHNwYWNlOlx0XHQlbHVcbiIsDQo+ID4gbGFyZ2VzdF9mcmVlKTsNCj4gPiArwqDCoMKgwqDC
oMKgwqBpZiAodG90YWxfZnJlZSkNCj4gPiArwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
c2VxX3ByaW50ZihtLCAiRXh0ZXJuYWwgTWVtb3J5DQo+ID4gRnJhZ2VtZW50YXRpb246XHQlbHUl
JVxuIiwNCj4gIkZyYWdtZW50YXRpb24iDQo+IA0KPiA+IA0KPiA+ICvCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgMTAwLSgxMDAqbGFyZ2VzdF9mcmVlL3RvdGFs
X2ZyZWUpKTsNCj4gPiArwqDCoMKgwqDCoMKgwqBlbHNlDQo+ID4gK8KgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoHNlcV9wdXRzKG0sICJFeHRlcm5hbCBNZW1vcnkNCj4gPiBGcmFnZW1lbnRh
dGlvbjpcdDAlJVxuIik7DQo+ICJGcmFnbWVudGF0aW9uIg0KDQpPb3BzISBUaGFua3MuDQoNCj4g
Wy4uLl0NCj4gPiANCj4gPiArc3RhdGljIGNvbnN0IHN0cnVjdCBmaWxlX29wZXJhdGlvbnMgZGVi
dWdfbW9kdWxlX2ZyYWdfb3BlcmF0aW9ucyA9DQo+ID4gew0KPiA+ICvCoMKgwqDCoMKgwqDCoC5v
cGVuwqDCoMKgwqDCoMKgwqA9IHByb2NfbW9kdWxlX2ZyYWdfZGVidWdfb3BlbiwNCj4gPiArwqDC
oMKgwqDCoMKgwqAucmVhZMKgwqDCoMKgwqDCoMKgPSBzZXFfcmVhZCwNCj4gPiArwqDCoMKgwqDC
oMKgwqAubGxzZWVrwqDCoMKgwqDCoD0gc2VxX2xzZWVrLA0KPiA+ICvCoMKgwqDCoMKgwqDCoC5y
ZWxlYXNlwqDCoMKgwqA9IHNpbmdsZV9yZWxlYXNlLA0KPiA+ICt9Ow0KPiA+IA0KPiA+ICtzdGF0
aWMgdm9pZCBkZWJ1Z19tb2RmcmFnX2luaXQodm9pZCkNCj4gPiArew0KPiA+ICvCoMKgwqDCoMKg
wqDCoGRlYnVnZnNfY3JlYXRlX2ZpbGUoIm1vZGZyYWdpbmZvIiwgMHgwNDAwLCBOVUxMLCBOVUxM
LA0KPiA+ICvCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgJmRl
YnVnX21vZHVsZV9mcmFnX29wZXJhdGlvbnMpOw0KPiAweDA0MDAgaXMgMDIwMDAsIHdoaWNoIGlz
IHRoZSBzZXRnaWQgYml0LiBJIHRoaW5rIHlvdSBtZWFudCB0byB0eXBlDQo+IDA0MDA/DQoNClll
cywgdGhhbmtzLg==
