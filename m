Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 98F6C6B007E
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 13:44:11 -0400 (EDT)
Received: by mail-pf0-f179.google.com with SMTP id n5so142406478pfn.2
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 10:44:11 -0700 (PDT)
Received: from smtp-outbound-2.vmware.com (smtp-outbound-2.vmware.com. [208.91.2.13])
        by mx.google.com with ESMTPS id by10si10191754pab.168.2016.03.28.10.44.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Mar 2016 10:44:10 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: Re: [PATCH v2 1/2] x86/mm: TLB_REMOTE_SEND_IPI should count pages
Date: Mon, 28 Mar 2016 17:44:09 +0000
Message-ID: <DB6272D6-8392-45E6-A93A-8A8F3A5B8FB2@vmware.com>
References: <1458980705-121507-1-git-send-email-namit@vmware.com>
 <1458980705-121507-2-git-send-email-namit@vmware.com>
In-Reply-To: <1458980705-121507-2-git-send-email-namit@vmware.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <8EEF474E3F37434CA8B72ED2DF6E1F53@vmware.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "mgorman@suse.de" <mgorman@suse.de>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "riel@redhat.com" <riel@redhat.com>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "luto@kernel.org" <luto@kernel.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "jmarchan@redhat.com" <jmarchan@redhat.com>, "hughd@google.com" <hughd@google.com>, "vdavydov@virtuozzo.com" <vdavydov@virtuozzo.com>, "minchan@kernel.org" <minchan@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

VGhlIGNvbW1pdCBtZXNzYWdlIHNob3VsZCBoYXZlIHNhaWQ6DQoNCkZpeGVzOiA1Yjc0MjgzYWIy
NTFiOWRiNTVjYmJlMzFkMTljYTcyNDgyMTAzMjkwDQoNCihhbmQgbm90IHdoYXQgaXQgY3VycmVu
dGx5IHNheXMpLg0KTGV0IG1lIGtub3cgd2hldGhlciB0byBzdWJtaXQgdjMuDQoNCg0KTmFkYXYN
Cg0KT24gMy8yNi8xNiwgMToyNSBBTSwgIk5hZGF2IEFtaXQiIDxuYW1pdEB2bXdhcmUuY29tPiB3
cm90ZToNCg0KPlRMQl9SRU1PVEVfU0VORF9JUEkgd2FzIHJlY2VudGx5IGludHJvZHVjZWQsIGJ1
dCBpdCBjb3VudHMgYnl0ZXMgaW5zdGVhZA0KPm9mIHBhZ2VzLiBJbiBhZGRpdGlvbiwgaXQgZG9l
cyBub3QgcmVwb3J0IGNvcnJlY3RseSB0aGUgY2FzZSBpbiB3aGljaA0KPmZsdXNoX3RsYl9wYWdl
IGZsdXNoZXMgYSBwYWdlLiBGaXggaXQgdG8gYmUgY29uc2lzdGVudCB3aXRoIG90aGVyIFRMQg0K
PmNvdW50ZXJzLg0KPg0KPkZpeGVzOiA0NTk1Zjk2MjBjZGE4YTFlOTczNTg4ZTc0M2NmNWY4NDM2
ZGQyMGM2DQo+DQo+U2lnbmVkLW9mZi1ieTogTmFkYXYgQW1pdCA8bmFtaXRAdm13YXJlLmNvbT4N
Cj4tLS0NCj4gYXJjaC94ODYvbW0vdGxiLmMgfCAxMiArKysrKysrKystLS0NCj4gMSBmaWxlIGNo
YW5nZWQsIDkgaW5zZXJ0aW9ucygrKSwgMyBkZWxldGlvbnMoLSkNCj4NCj5kaWZmIC0tZ2l0IGEv
YXJjaC94ODYvbW0vdGxiLmMgYi9hcmNoL3g4Ni9tbS90bGIuYw0KPmluZGV4IDhmNGNjM2QuLjVm
YjZhZGEgMTAwNjQ0DQo+LS0tIGEvYXJjaC94ODYvbW0vdGxiLmMNCj4rKysgYi9hcmNoL3g4Ni9t
bS90bGIuYw0KPkBAIC0xMDYsOCArMTA2LDYgQEAgc3RhdGljIHZvaWQgZmx1c2hfdGxiX2Z1bmMo
dm9pZCAqaW5mbykNCj4gDQo+IAlpZiAoZi0+Zmx1c2hfbW0gIT0gdGhpc19jcHVfcmVhZChjcHVf
dGxic3RhdGUuYWN0aXZlX21tKSkNCj4gCQlyZXR1cm47DQo+LQlpZiAoIWYtPmZsdXNoX2VuZCkN
Cj4tCQlmLT5mbHVzaF9lbmQgPSBmLT5mbHVzaF9zdGFydCArIFBBR0VfU0laRTsNCj4gDQo+IAlj
b3VudF92bV90bGJfZXZlbnQoTlJfVExCX1JFTU9URV9GTFVTSF9SRUNFSVZFRCk7DQo+IAlpZiAo
dGhpc19jcHVfcmVhZChjcHVfdGxic3RhdGUuc3RhdGUpID09IFRMQlNUQVRFX09LKSB7DQo+QEAg
LTEzNSwxMiArMTMzLDIwIEBAIHZvaWQgbmF0aXZlX2ZsdXNoX3RsYl9vdGhlcnMoY29uc3Qgc3Ry
dWN0IGNwdW1hc2sgKmNwdW1hc2ssDQo+IAkJCQkgdW5zaWduZWQgbG9uZyBlbmQpDQo+IHsNCj4g
CXN0cnVjdCBmbHVzaF90bGJfaW5mbyBpbmZvOw0KPisNCj4rCWlmIChlbmQgPT0gMCkNCj4rCQll
bmQgPSBzdGFydCArIFBBR0VfU0laRTsNCj4gCWluZm8uZmx1c2hfbW0gPSBtbTsNCj4gCWluZm8u
Zmx1c2hfc3RhcnQgPSBzdGFydDsNCj4gCWluZm8uZmx1c2hfZW5kID0gZW5kOw0KPiANCj4gCWNv
dW50X3ZtX3RsYl9ldmVudChOUl9UTEJfUkVNT1RFX0ZMVVNIKTsNCj4tCXRyYWNlX3RsYl9mbHVz
aChUTEJfUkVNT1RFX1NFTkRfSVBJLCBlbmQgLSBzdGFydCk7DQo+KwlpZiAoZW5kID09IFRMQl9G
TFVTSF9BTEwpDQo+KwkJdHJhY2VfdGxiX2ZsdXNoKFRMQl9SRU1PVEVfU0VORF9JUEksIFRMQl9G
TFVTSF9BTEwpOw0KPisJZWxzZQ0KPisJCXRyYWNlX3RsYl9mbHVzaChUTEJfUkVNT1RFX1NFTkRf
SVBJLA0KPisJCQkJKGVuZCAtIHN0YXJ0KSA+PiBQQUdFX1NISUZUKTsNCj4rDQo+IAlpZiAoaXNf
dXZfc3lzdGVtKCkpIHsNCj4gCQl1bnNpZ25lZCBpbnQgY3B1Ow0KPiANCj4tLSANCj4yLjUuMA0K
Pg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
