Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B5F2F8E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 14:58:44 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d22-v6so10635041pfn.3
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 11:58:44 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id b4-v6si121913pla.46.2018.09.24.11.58.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Sep 2018 11:58:43 -0700 (PDT)
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Subject: Re: [PATCH v6 2/4] x86/modules: Increase randomization for modules
Date: Mon, 24 Sep 2018 18:57:35 +0000
Message-ID: <1537815484.19013.48.camel@intel.com>
References: <1536874298-23492-1-git-send-email-rick.p.edgecombe@intel.com>
	 <1536874298-23492-3-git-send-email-rick.p.edgecombe@intel.com>
	 <CAGXu5jJ9nZYbVn5xdi7nsMJRD6ScLeWP2DWjrD8yEfwi-XXcRw@mail.gmail.com>
In-Reply-To: <CAGXu5jJ9nZYbVn5xdi7nsMJRD6ScLeWP2DWjrD8yEfwi-XXcRw@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <7C7B10887068584C86F3A3ACD6F60B7C@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "keescook@chromium.org" <keescook@chromium.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "daniel@iogearbox.net" <daniel@iogearbox.net>, "jannh@google.com" <jannh@google.com>, "arjan@linux.intel.com" <arjan@linux.intel.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Hansen, Dave" <dave.hansen@intel.com>

T24gRnJpLCAyMDE4LTA5LTIxIGF0IDEyOjA1IC0wNzAwLCBLZWVzIENvb2sgd3JvdGU6DQo+IE9u
IFRodSwgU2VwIDEzLCAyMDE4IGF0IDI6MzEgUE0sIFJpY2sgRWRnZWNvbWJlDQo+IDxyaWNrLnAu
ZWRnZWNvbWJlQGludGVsLmNvbT4gd3JvdGU6DQo+IEkgd291bGQgZmluZCB0aGlzIG11Y2ggbW9y
ZSByZWFkYWJsZSBhczoNCj4gc3RhdGljIHVuc2lnbmVkIGxvbmcgZ2V0X21vZHVsZV92bWFsbG9j
X3N0YXJ0KHZvaWQpDQo+IHsNCj4gwqDCoMKgwqDCoMKgwqB1bnNpZ25lZCBsb25nIGFkZHIgPSBN
T0RVTEVTX1ZBRERSOw0KPiANCj4gwqDCoMKgwqDCoMKgwqBpZiAoa2FzbHJfcmFuZG9taXplX2Jh
c2UoKSkNCj4gwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoGFkZHIgKz0gZ2V0X21vZHVsZV9s
b2FkX29mZnNldCgpOw0KPiANCj4gwqDCoMKgwqDCoMKgwqBpZiAoa2FzbHJfcmFuZG9taXplX2Vh
Y2hfbW9kdWxlKCkpDQo+IMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoGFkZHIgKz0gZ2V0
X21vZHVsZXNfcmFuZF9sZW4oKTsNCj4gDQo+IMKgwqDCoMKgwqDCoMKgcmV0dXJuIGFkZHI7DQo+
IH0NClRoYW5rcywgdGhhdCBsb29rcyBiZXR0ZXIuDQoNCj4gDQo+ID4gwqB2b2lkICptb2R1bGVf
YWxsb2ModW5zaWduZWQgbG9uZyBzaXplKQ0KPiA+IMKgew0KPiA+IEBAIC04NCwxNiArMjAxLDE4
IEBAIHZvaWQgKm1vZHVsZV9hbGxvYyh1bnNpZ25lZCBsb25nIHNpemUpDQo+ID4gwqDCoMKgwqDC
oMKgwqDCoGlmIChQQUdFX0FMSUdOKHNpemUpID4gTU9EVUxFU19MRU4pDQo+ID4gwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqByZXR1cm4gTlVMTDsNCj4gPiANCj4gPiAtwqDCoMKgwqDC
oMKgwqBwID0gX192bWFsbG9jX25vZGVfcmFuZ2Uoc2l6ZSwgTU9EVUxFX0FMSUdOLA0KPiA+IC3C
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgTU9EVUxFU19WQUREUiArDQo+ID4gZ2V0X21vZHVsZV9sb2FkX29mZnNldCgp
LA0KPiA+IC3CoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgTU9EVUxFU19FTkQsIEdGUF9LRVJORUwsDQo+ID4gLcKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqBQQUdFX0tFUk5FTF9FWEVDLCAwLCBOVU1BX05PX05PREUsDQo+ID4gLcKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqBfX2J1aWx0aW5fcmV0dXJuX2FkZHJlc3MoMCkpOw0KPiA+ICvCoMKgwqDCoMKgwqDCoHAg
PSB0cnlfbW9kdWxlX3JhbmRvbWl6ZV9lYWNoKHNpemUpOw0KPiA+ICsNCj4gPiArwqDCoMKgwqDC
oMKgwqBpZiAoIXApDQo+ID4gK8KgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoHAgPSBfX3Zt
YWxsb2Nfbm9kZV9yYW5nZShzaXplLCBNT0RVTEVfQUxJR04sDQo+ID4gK8KgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgZ2V0X21vZHVs
ZV92bWFsbG9jX3N0YXJ0KCksIE1PRFVMRVNfRU5ELA0KPiA+ICvCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoEdGUF9LRVJORUwsIFBB
R0VfS0VSTkVMX0VYRUMsIDAsDQo+ID4gK8KgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgTlVNQV9OT19OT0RFLCBfX2J1aWx0aW5fcmV0
dXJuX2FkZHJlc3MoMCkpOw0KPiBJbnN0ZWFkIG9mIGhhdmluZyB0d28gb3Blbi1jb2RlZCBfX3Zt
YWxsb2Nfbm9kZV9yYW5nZSgpIGNhbGxzIGxlZnQgaW4NCj4gdGhpcyBhZnRlciB0aGUgY2hhbmdl
LCBjYW4gdGhpcyBiZSBkb25lIGluIHRlcm1zIG9mIGEgY2FsbCB0bw0KPiB0cnlfbW9kdWxlX2Fs
bG9jKCkgaW5zdGVhZD8gSSBzZWUgdGhleSdyZSBzbGlnaHRseSBkaWZmZXJlbnQsIGJ1dCBpdA0K
PiBtaWdodCBiZSBuaWNlIGZvciBtYWtpbmcgdGhlIHR3byBwYXRocyBzaGFyZSBtb3JlIGNvZGUu
DQpOb3Qgc3VyZSB3aGF0IHlvdSBtZWFuLiBBY3Jvc3MgdGhlIHdob2xlIGNoYW5nZSwgdGhlcmUg
aXMgb25lIGNhbGwNCnRvwqBfX3ZtYWxsb2Nfbm9kZV9yYW5nZSwgYW5kIG9uZSB0b8KgX192bWFs
bG9jX25vZGVfdHJ5X2FkZHIu
