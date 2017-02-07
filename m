Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id A80C66B0253
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 12:35:36 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id h10so119174882ith.2
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 09:35:36 -0800 (PST)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0106.outbound.protection.outlook.com. [104.47.34.106])
        by mx.google.com with ESMTPS id m206si12415998ioa.88.2017.02.07.09.35.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 09:35:35 -0800 (PST)
From: "Kani, Toshimitsu" <toshi.kani@hpe.com>
Subject: Re: [PATCH] mm: fix a overflow in test_pages_in_a_zone()
Date: Tue, 7 Feb 2017 17:35:34 +0000
Message-ID: <1486492248.2029.34.camel@hpe.com>
References: <1486467299-22648-1-git-send-email-zhongjiang@huawei.com>
In-Reply-To: <1486467299-22648-1-git-send-email-zhongjiang@huawei.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <CC36BD5F48961340B0092590EE6079BA@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "zhongjiang@huawei.com" <zhongjiang@huawei.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "vbabka@suse.cz" <vbabka@suse.cz>

T24gVHVlLCAyMDE3LTAyLTA3IGF0IDE5OjM0ICswODAwLCB6aG9uZ2ppYW5nIHdyb3RlOg0KPiBG
cm9tOiB6aG9uZyBqaWFuZyA8emhvbmdqaWFuZ0BodWF3ZWkuY29tPg0KPiANCj4gd2hlbiB0aGUg
bWFpbGxpbmUgaW50cm9kdWNlIHRoZSBjb21taXQgYTk2ZGZkZGJjYzA0DQo+ICgiYmFzZS9tZW1v
cnksIGhvdHBsdWc6IGZpeCBhIGtlcm5lbCBvb3BzIGluIHNob3dfdmFsaWRfem9uZXMoKSIpLA0K
PiBpdCBvYnRhaW5zIHRoZSB2YWxpZCBzdGFydCBhbmQgZW5kIHBmbiBmcm9tIHRoZSBnaXZlbiBw
Zm4gcmFuZ2UuDQo+IFRoZSB2YWxpZCBzdGFydCBwZm4gY2FuIGZpeCB0aGUgYWN0dWFsIGlzc3Vl
LCBidXQgaXQgaW50cm9kdWNlDQo+IGFub3RoZXIgaXNzdWUuIFRoZSB2YWxpZCBlbmQgcGZuIHdp
bGwgbWF5IGV4Y2VlZCB0aGUgZ2l2ZW4gZW5kX3Bmbi4NCj4gDQo+IEFodGhvdWdoIHRoZSBpbmNv
cnJlY3Qgb3ZlcmZsb3cgd2lsbCBub3QgcmVzdWx0IGluIGFjdHVhbCBwcm9ibGVtDQo+IGF0IHBy
ZXNlbnQsIGJ1dCBJIHRoaW5rIGl0IG5lZWQgdG8gYmUgZml4ZWQuDQoNClllcywgdGVzdF9wYWdl
c19pbl9hX3pvbmUoKSBhc3N1bWVzIHRoYXQgZW5kX3BmbiBpcyBhbGlnbmVkIGJ5DQpNQVhfT1JE
RVJfTlJfUEFHRVMuICBUaGlzIGlzIHRydWUgZm9yIGJvdGggY2FsbGVycywgc2hvd192YWxpZF96
b25lcygpDQphbmQgX19vZmZsaW5lX3BhZ2VzKCkuICBJIGRpZCBub3QgaW50cm9kdWNlIHRoaXMg
YXNzdW1wdGlvbi4gOi0pDQoNCkFzIHlvdSBwb2ludGVkIG91dCwgaXQgaXMgcHJ1ZGVudCB0byBy
ZW1vdmUgdGhpcyBhc3N1bXB0aW9uIGZvciBmdXR1cmUNCnVzYWdlcy4gIEluIHRoaXMgY2FzZSwg
SSB0aGluayB3ZSBuZWVkIHRoZSBmb2xsb3dpbmcgY2hhbmdlIGFzIHdlbGwuDQoNCmRpZmYgLS1n
aXQgYS9tbS9tZW1vcnlfaG90cGx1Zy5jIGIvbW0vbWVtb3J5X2hvdHBsdWcuYw0KaW5kZXggYTQw
YzBjMi4uMDljOGI5OSAxMDA2NDQNCi0tLSBhL21tL21lbW9yeV9ob3RwbHVnLmMNCisrKyBiL21t
L21lbW9yeV9ob3RwbHVnLmMNCkBAIC0xNTEzLDcgKzE1MTMsNyBAQCBpbnQgdGVzdF9wYWdlc19p
bl9hX3pvbmUodW5zaWduZWQgbG9uZyBzdGFydF9wZm4sDQp1bnNpZ25lZCBsb25nIGVuZF9wZm4s
DQrCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoHdoaWxlICgoaSA8IE1BWF9PUkRFUl9O
Ul9QQUdFUykgJiYNCsKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoCFwZm5fdmFsaWRfd2l0aGluKHBmbiArIGkpKQ0KwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgaSsrOw0KLcKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoGlmIChpID09IE1BWF9PUkRFUl9OUl9QQUdFUykNCivCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqBpZiAoKGkgPT0gTUFYX09SREVSX05SX1BBR0VTKSB8fCAocGZuICsgaSA+PSBlbmRf
cGZuKSkNCsKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoGNv
bnRpbnVlOw0KwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqBwYWdlID0gcGZuX3RvX3Bh
Z2UocGZuICsgaSk7DQrCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoGlmICh6b25lICYm
IHBhZ2Vfem9uZShwYWdlKSAhPSB6b25lKQ0KDQoNClRoYW5rcywNCi1Ub3NoaQ0KDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
