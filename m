Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C7ACA6B0261
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 09:26:43 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id p66so435693613pga.4
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 06:26:43 -0800 (PST)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0092.outbound.protection.outlook.com. [104.47.33.92])
        by mx.google.com with ESMTPS id h22si31550379pli.285.2016.11.29.06.26.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 29 Nov 2016 06:26:42 -0800 (PST)
From: Matthew Wilcox <mawilcox@microsoft.com>
Subject: RE: [PATCH v3 24/33] radix-tree: Add radix_tree_split
Date: Tue, 29 Nov 2016 14:26:40 +0000
Message-ID: <SN1PR21MB007701814BA71EBCFBF2B884CB8D0@SN1PR21MB0077.namprd21.prod.outlook.com>
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
 <1480369871-5271-25-git-send-email-mawilcox@linuxonhyperv.com>
 <ebdda64e-2309-49cb-7d9c-1820e8783e1c@infradead.org>
In-Reply-To: <ebdda64e-2309-49cb-7d9c-1820e8783e1c@infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>, Matthew Wilcox <mawilcox@linuxonhyperv.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

RnJvbTogUmFuZHkgRHVubGFwIFttYWlsdG86cmR1bmxhcEBpbmZyYWRlYWQub3JnXQ0KPiA+ICt2
b2lkIHJhZGl4X3RyZWVfaXRlcl9yZXBsYWNlKHN0cnVjdCByYWRpeF90cmVlX3Jvb3QgKiwNCj4g
PiArCQljb25zdCBzdHJ1Y3QgcmFkaXhfdHJlZV9pdGVyICosIHZvaWQgKipzbG90LCB2b2lkICpp
dGVtKTsNCj4gDQo+ID4gK2ludCByYWRpeF90cmVlX3NwbGl0KHN0cnVjdCByYWRpeF90cmVlX3Jv
b3QgKiwgdW5zaWduZWQgbG9uZyBpbmRleCwNCj4gPiArCQkJdW5zaWduZWQgbmV3X29yZGVyKTsN
Cj4gDQo+IGFuZCBhYm92ZToNCj4gDQo+IEFzIGluZGljYXRlZCBpbiBDb2RpbmdTdHlsZToNCj4g
SW4gZnVuY3Rpb24gcHJvdG90eXBlcywgaW5jbHVkZSBwYXJhbWV0ZXIgbmFtZXMgd2l0aCB0aGVp
ciBkYXRhIHR5cGVzLg0KPiBBbHRob3VnaCB0aGlzIGlzIG5vdCByZXF1aXJlZCBieSB0aGUgQyBs
YW5ndWFnZSwgaXQgaXMgcHJlZmVycmVkIGluIExpbnV4DQo+IGJlY2F1c2UgaXQgaXMgYSBzaW1w
bGUgd2F5IHRvIGFkZCB2YWx1YWJsZSBpbmZvcm1hdGlvbiBmb3IgdGhlIHJlYWRlci4NCg0KSSB0
aGluayB0aGUgcnVsZSBoZXJlIHNob3VsZCBiZSBhIGJpdCBtb3JlIG51YW5jZWQuICBJIHRoaW5r
IGl0IGlzIHBvc2l0aXZlbHkgY3JpbWluYWwgdG8gaGF2ZSBhbiB1bm5hbWVkICd1bnNpZ25lZCBs
b25nJyBvciAnYm9vbCcgaW4gYSBmdW5jdGlvbiBwcm90b3R5cGUuICBCdXQgd2hhdCBleHRyYSBp
bmZvcm1hdGlvbiBpcyBjb21tdW5pY2F0ZWQgYnkgYWRkaW5nICdyb290JyBhZnRlciAnc3RydWN0
IHJhZGl4X3RyZWVfcm9vdCAqJz8gIEkga25vdyBpdCdzIGEgcm9vdCwgeW91IHRvbGQgbWUgdGhh
dCB3aXRoIHRoZSBzdHJ1Y3R1cmUgbmFtZSENCg0KT2J2aW91c2x5IHNvbWV0aW1lcyBpdCB3b3Vs
ZCBiZSB1c2VmdWwsIGZvciBleGFtcGxlIGlmIHdlIGhhZCBhIGZ1bmN0aW9uIHRvIG1vdmUgYW4g
ZW50cnkgZnJvbSBvbmUgcmFkaXggdHJlZSB0byBhbm90aGVyLCB5b3UgbWlnaHQgd2FudCB0byBo
YXZlICdzdHJ1Y3QgcmFkaXhfdHJlZV9yb290ICpvbGQsIHN0cnVjdCByYWRpeF90cmVlX3Jvb3Qg
Km5ldycgYXMgdHdvIG9mIHlvdXIgcGFyYW1ldGVycy4NCg0KPiA+ICBpbnQgcmFkaXhfdHJlZV9q
b2luKHN0cnVjdCByYWRpeF90cmVlX3Jvb3QgKiwgdW5zaWduZWQgbG9uZyBpbmRleCwNCj4gPiAg
CQkJdW5zaWduZWQgbmV3X29yZGVyLCB2b2lkICopOw0KPiANCj4gWWVzLCB0aGUgc291cmNlIGZp
bGUgYWxyZWFkeSBvbWl0cyBzb21lIGZ1bmN0aW9uIHByb3RvdHlwZSBwYXJhbWV0ZXIgbmFtZXMs
DQo+IHNvIHRoZXNlIHBhdGNoZXMganVzdCBmb2xsb3cgdGhhdCB0cmFkaXRpb24uICBJdCdzIHdl
aXJkICh0byBtZSkgdGhvdWdoIHRoYXQNCj4gdGhlIGV4aXN0aW5nIGNvZGUgZXZlbiBtaXhlcyB0
aGlzIHN0eWxlIGluIG9uZSBmdW5jdGlvbiBwcm90b3R5cGUgKHNlZQ0KPiBpbW1lZC4gYWJvdmUp
Lg0KDQpJIGFncmVlIHRoYXQgdm9pZCAqIHNob3VsZCBwcm9iYWJseSBiZSBuYW1lZCAoYXMgbmV3
X2VudHJ5KS4gIE5hbWluZyBpbmRleCBhbmQgbmV3X29yZGVyIGlzIGNvcnJlY3QuICBCdXQgYWdh
aW4sIHRoZXJlJ3Mgbm8gdXNlZnVsIGluZm9ybWF0aW9uIGdpdmVuIGJ5IG5hbWluZyByb290Lg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
