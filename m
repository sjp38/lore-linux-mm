Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9FA886B003B
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 13:14:39 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so9519948pdj.14
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 10:14:39 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id cl4si14827145pbb.175.2014.07.21.10.14.38
        for <linux-mm@kvack.org>;
        Mon, 21 Jul 2014 10:14:38 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [RFC PATCH 2/3] x86, MCE: Avoid potential deadlock in MCE
 context
Date: Mon, 21 Jul 2014 17:14:06 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F32870C55@ORSMSX114.amr.corp.intel.com>
References: <1405478082-30757-1-git-send-email-gong.chen@linux.intel.com>
 <1405478082-30757-3-git-send-email-gong.chen@linux.intel.com>
 <20140721084737.GA10016@pd.tnic>
In-Reply-To: <20140721084737.GA10016@pd.tnic>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, "Chen, Gong" <gong.chen@linux.intel.com>
Cc: "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>

PiBUaGlzIHBhdGNoIGlzIG92ZXJlbmdpbmVlcmVkIGV2ZW4gdGhvdWdoIHdlIGFscmVhZHkgaGF2
ZSBib3RoIHByb2Nlc3MNCj4gY29udGV4dCB3b3JrIGFuZCBpcnEgd29yayBmYWNpbGl0aWVzIGlu
IHBsYWNlLg0KPg0KPiBXZSBhbHNvIGFscmVhZHkgaGF2ZSBtY2VfcmluZyB3aGVyZSB3ZSBhZGQg
TUNFIHNpZ25hdHVyZXMgaW4gI01DDQo+IGNvbnRleHQuIFdlbGwsIG9ubHkgZm9yIEFPIGVycm9y
cyB3aXRoIHVzYWJsZSBhZGRyZXNzZXMgZm9yIG5vdywgYXQNCj4gbGVhc3QuDQoNCldlJ3ZlIGV2
b2x2ZWQgYSBidW5jaCBvZiBtZWNoYW5pc21zOg0KDQoxKSBtY2VfcmluZzogdG8gcGFzcyBwZm4g
Zm9yIEFPIGVycm9ycyBmcm9tIE1DRSBjb250ZXh0IHRvIGEgd29yayB0aHJlYWQNCjIpIG1jZV9p
bmZvOiB0byBwYXNzIHBmbiBmb3IgQVIgZXJyb3JzIGZyb20gTUNFIGNvbnRleHQgdG8gc2FtZSBw
cm9jZXNzIHJ1bm5pbmcgaW4gcHJvY2VzcyBjb250ZXh0DQozKSBtY2VfbG9nOiB0byBwYXNzIGVu
dGlyZSAibWNlIiBzdHJ1Y3R1cmVzIGZyb20gYW55IGNvbnRleHQgKE1DRSwgQ01DSSwgb3IgaW5p
dC10aW1lKSB0byAvZGV2L21jZWxvZw0KDQpzb21ldGhpbmcgc2ltcGxlciBtaWdodCBiZSBuaWNl
IC0gYnV0IGEgZ2VuZXJpYyB0aGluZyB0aGF0IGlzIG92ZXJraWxsIGZvciBlYWNoIG9mIHRoZQ0K
c3BlY2lhbGl6ZWQgdXNlcyBtaWdodCBub3QgbmVjZXNzYXJpbHkgYmUgYW4gaW1wcm92ZW1lbnQu
DQoNCkUuZy4gIzMgYWJvdmUgaGFzIGEgZml4ZWQgY2FwYWNpdHkgKE1DRV9MT0dfTEVOKSBhbmQg
anVzdCBkcm9wcyBhbnkgZXh0cmFzIGlmIGl0IHNob3VsZCBmaWxsDQp1cCAoZGVsaWJlcmF0ZWx5
LCBiZWNhdXNlIHdlIGFsbW9zdCBhbHdheXMgcHJlZmVyIHRvIHNlZSB0aGUgZmlyc3QgYnVuY2gg
b2YgZXJyb3JzIHJhdGhlcg0KdGhhbiB0aGUgbmV3ZXN0KS4NCg0KPiBJIHRoaW5rIGl0IHdvdWxk
IGJlIGEgKmxvdCogc2ltcGxlciBpZiB5b3UgbW9kaWZ5IHRoZSBsb2dpYyB0byBwdXQgYWxsDQo+
IGVycm9ycyBpbnRvIHRoZSByaW5nIGFuZCByZW1vdmUgdGhlIGNhbGwgY2hhaW4gY2FsbCBmcm9t
IG1jZV9sb2coKS4NCg0KSSB3YXMgYWN0dWFsbHkgd29uZGVyaW5nIGFib3V0IGdvaW5nIGluIHRo
ZSBvdGhlciBkaXJlY3Rpb24uIE1ha2UgdGhlDQovZGV2L21jZWxvZyBjb2RlIHJlZ2lzdGVyIGEg
bm90aWZpZXIgb24geDg2X21jZV9kZWNvZGVyX2NoYWluIChhbmQNCnBlcmhhcHMgbW92ZSBhbGwg
dGhlIC9kZXYvbWNlbG9nIGZ1bmN0aW9ucyBvdXQgb2YgbWNlLmMgaW50byBhbiBhY3R1YWwNCmRy
aXZlciBmaWxlKS4gIFRoZW4gdXNlIENoZW4gR29uZydzIE5NSSBzYWZlIGNvZGUgdG8ganVzdCB1
bmNvbmRpdGlvbmFsbHkNCm1ha2Ugc2FmZSBjb3BpZXMgb2YgYW55dGhpbmcgdGhhdCBnZXRzIHBh
c3NlZCB0byBtY2VfbG9nKCkgYW5kIHJ1biBhbGwNCnRoZSBub3RpZmllcnMgZnJvbSBoaXMgZG9f
bWNlX2lycXdvcmsoKS4NCg0KLVRvbnkNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
