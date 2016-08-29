Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 473EA83102
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 18:00:55 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w136so3671798oie.2
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 15:00:55 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0127.outbound.protection.outlook.com. [104.47.41.127])
        by mx.google.com with ESMTPS id w63si26499421otb.162.2016.08.29.15.00.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 29 Aug 2016 15:00:46 -0700 (PDT)
From: "Kani, Toshimitsu" <toshi.kani@hpe.com>
Subject: Re: [PATCH v4 RESEND 0/2] Align mmap address for DAX pmd mappings
Date: Mon, 29 Aug 2016 22:00:43 +0000
Message-ID: <1472508000.1532.59.camel@hpe.com>
References: <1472497881-9323-1-git-send-email-toshi.kani@hpe.com>
	 <20160829204842.GA27286@node.shutemov.name>
	 <1472506310.1532.47.camel@hpe.com>
In-Reply-To: <1472506310.1532.47.camel@hpe.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <7A35FDC77690ED41A514F00658A38AA0@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "kirill@shutemov.name" <kirill@shutemov.name>
Cc: "hughd@google.com" <hughd@google.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "adilger.kernel@dilger.ca" <adilger.kernel@dilger.ca>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "tytso@mit.edu" <tytso@mit.edu>, "david@fromorbit.com" <david@fromorbit.com>, "jack@suse.cz" <jack@suse.cz>

T24gTW9uLCAyMDE2LTA4LTI5IGF0IDE1OjMxIC0wNjAwLCBLYW5pLCBUb3NoaW1pdHN1IHdyb3Rl
Og0KPiBPbiBNb24sIDIwMTYtMDgtMjkgYXQgMjM6NDggKzAzMDAsIEtpcmlsbCBBLiBTaHV0ZW1v
diB3cm90ZToNCj4gPiANCj4gPiBPbiBNb24sIEF1ZyAyOSwgMjAxNiBhdCAwMToxMToxOVBNIC0w
NjAwLCBUb3NoaSBLYW5pIHdyb3RlOg0KPiA+ID4gDQo+ID4gPiANCj4gPiA+IFdoZW4gQ09ORklH
X0ZTX0RBWF9QTUQgaXMgc2V0LCBEQVggc3VwcG9ydHMgbW1hcCgpIHVzaW5nIHBtZCBwYWdlDQo+
ID4gPiBzaXplLsKgwqBUaGlzIGZlYXR1cmUgcmVsaWVzIG9uIGJvdGggbW1hcCB2aXJ0dWFsIGFk
ZHJlc3MgYW5kIEZTDQo+ID4gPiBibG9jayAoaS5lLiBwaHlzaWNhbCBhZGRyZXNzKSB0byBiZSBh
bGlnbmVkIGJ5IHRoZSBwbWQgcGFnZSBzaXplLg0KPiA+ID4gVXNlcnMgY2FuIHVzZSBta2ZzIG9w
dGlvbnMgdG8gc3BlY2lmeSBGUyB0byBhbGlnbiBibG9jaw0KPiA+ID4gYWxsb2NhdGlvbnMuIEhv
d2V2ZXIsIGFsaWduaW5nIG1tYXAgYWRkcmVzcyByZXF1aXJlcyBjb2RlIGNoYW5nZXMNCj4gPiA+
IHRvIGV4aXN0aW5nIGFwcGxpY2F0aW9ucyBmb3IgcHJvdmlkaW5nIGEgcG1kLWFsaWduZWQgYWRk
cmVzcyB0bw0KPiA+ID4gbW1hcCgpLg0KPiA+ID4gDQo+ID4gPiBGb3IgaW5zdGFuY2UsIGZpbyB3
aXRoICJpb2VuZ2luZT1tbWFwIiBwZXJmb3JtcyBJL09zIHdpdGggbW1hcCgpDQo+ID4gPiBbMV0u
IEl0IGNhbGxzIG1tYXAoKSB3aXRoIGEgTlVMTCBhZGRyZXNzLCB3aGljaCBuZWVkcyB0byBiZQ0K
PiA+ID4gY2hhbmdlZCB0byBwcm92aWRlIGEgcG1kLWFsaWduZWQgYWRkcmVzcyBmb3IgdGVzdGlu
ZyB3aXRoIERBWCBwbWQNCj4gPiA+IG1hcHBpbmdzLiBDaGFuZ2luZyBhbGwgYXBwbGljYXRpb25z
IHRoYXQgY2FsbCBtbWFwKCkgd2l0aCBOVUxMIGlzDQo+ID4gPiB1bmRlc2lyYWJsZS4NCj4gPiA+
IA0KPiA+ID4gVGhpcyBwYXRjaC1zZXQgZXh0ZW5kcyBmaWxlc3lzdGVtcyB0byBhbGlnbiBhbiBt
bWFwIGFkZHJlc3MgZm9yDQo+ID4gPiBhIERBWCBmaWxlIHNvIHRoYXQgdW5tb2RpZmllZCBhcHBs
aWNhdGlvbnMgY2FuIHVzZSBEQVggcG1kDQo+ID4gPiBtYXBwaW5ncy4NCj4gPiANCj4gPiArSHVn
aA0KPiA+IA0KPiA+IENhbiB3ZSBnZXQgaXQgdXNlZCBmb3Igc2htZW0vdG1wZnMgdG9vPw0KPiA+
IEkgZG9uJ3QgdGhpbmsgd2Ugc2hvdWxkIGR1cGxpY2F0ZSBlc3NlbnRpYWxseSB0aGUgc2FtZQ0K
PiA+IGZ1bmN0aW9uYWxpdHkgaW4gbXVsdGlwbGUgcGxhY2VzLg0KPiANCj4gSGVyZSBpcyBteSBi
cmllZiBhbmFseXNpcyB3aGVuIEkgaGFkIGxvb2tlZCBhdCB0aGUgSHVnaCdzIHBhdGNoIGxhc3QN
Cj4gdGltZSAoYmVmb3JlwqBzaG1lbV9nZXRfdW5tYXBwZWRfYXJlYSgpIHdhcyBhY2NlcHRlZCku
DQo+IGh0dHBzOi8vcGF0Y2h3b3JrLmtlcm5lbC5vcmcvcGF0Y2gvODkxNjc0MS8NCj4gDQo+IEJl
c2lkZXMgc29tZSBkaWZmZXJlbmNlcyBpbiB0aGUgbG9naWMsIGV4LiBzaG1lbV9nZXRfdW5tYXBw
ZWRfYXJlYSgpDQo+IGFsd2F5cyBjYWxsc8KgY3VycmVudC0+bW0tPmdldF91bm1hcHBlZF9hcmVh
IHR3aWNlLCB5ZXMsIHRoZXkNCj4gYmFzaWNhbGx5IHByb3ZpZGUgdGhlIHNhbWUgZnVuY3Rpb25h
bGl0eS4NCj4gDQo+IEkgdGhpbmsgb25lIGlzc3VlIGlzIHRoYXQgc2htZW1fZ2V0X3VubWFwcGVk
X2FyZWEoKSBjaGVja3Mgd2l0aCBpdHMNCj4gc3RhdGljIGZsYWcgJ3NobWVtX2h1Z2UnLCBhbmQg
YWRkaXRpbmFsbHkgZGVhbHMgd2l0aCBTSE1FTV9IVUdFX0RFTlkNCj4gYW5kwqBTSE1FTV9IVUdF
X0ZPUkNFIGNhc2VzLiDCoEl0IGFsc28gaGFuZGxlcyBub24tZmlsZSBjYXNlIGZvcg0KPiAhU0hN
RU1fSFVHRV9GT1JDRS4NCg0KTG9va2luZyBmdXJ0aGVyLCB0aGVzZSBzaG1lbV9odWdlIGhhbmRs
aW5ncyBvbmx5IGNoZWNrIHByZS1jb25kaXRpb25zLg0KwqBTbywgd2Ugc2hvdWxkIGJlIGFibGUg
dG8gbWFrZSBzaG1lbV9nZXRfdW5tYXBwZWRfYXJlYSgpIGFzIGEgd3JhcHBlciwNCndoaWNoIGNo
ZWNrcyBzdWNoIHNobWVtLXNwZWNpZmljIGNvbml0aW9ucywgYW5kIHRoZW4NCmNhbGzCoF9fdGhw
X2dldF91bm1hcHBlZF9hcmVhKCkgZm9yIHRoZSBhY3R1YWwgd29yay4gwqBBbGwgREFYLXNwZWNp
ZmljDQpjaGVja3MgYXJlIHBlcmZvcm1lZCBpbiB0aHBfZ2V0X3VubWFwcGVkX2FyZWEoKSBhcyB3
ZWxsLiDCoFdlIGNhbiBtYWtlDQrCoF9fdGhwX2dldF91bm1hcHBlZF9hcmVhKCkgYXMgYSBjb21t
b24gZnVuY3Rpb24uDQoNCkknZCBwcmVmZXIgdG8gbWFrZSBzdWNoIGNoYW5nZSBhcyBhIHNlcGFy
YXRlIGl0ZW0sIGJ1dCBJIGNhbiBpbmNsdWRlIGl0DQp0byB0aGlzIHBhdGNoIHNlcmllcyBpZiBu
ZWVkZWQuwqANCg0KVGhhbmtzLA0KLVRvc2hpDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
