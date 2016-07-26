Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 708CF6B025F
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 16:17:11 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h186so779657pfg.2
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 13:17:11 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id 140si2162899pfx.153.2016.07.26.13.17.05
        for <linux-mm@kvack.org>;
        Tue, 26 Jul 2016 13:17:05 -0700 (PDT)
From: "Roberts, William C" <william.c.roberts@intel.com>
Subject: RE: [kernel-hardening] [PATCH] [RFC] Introduce mmap randomization
Date: Tue, 26 Jul 2016 20:17:04 +0000
Message-ID: <476DC76E7D1DF2438D32BFADF679FC560125F2D5@ORSMSX103.amr.corp.intel.com>
References: <1469557346-5534-1-git-send-email-william.c.roberts@intel.com>
	 <1469557346-5534-2-git-send-email-william.c.roberts@intel.com>
 <1469563923.10218.13.camel@redhat.com>
In-Reply-To: <1469563923.10218.13.camel@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "jason@lakedaemon.net" <jason@lakedaemon.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "keescook@chromium.org" <keescook@chromium.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "nnk@google.com" <nnk@google.com>, "jeffv@google.com" <jeffv@google.com>, "salyzyn@android.com" <salyzyn@android.com>, "dcashman@android.com" <dcashman@android.com>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBSaWsgdmFuIFJpZWwgW21haWx0
bzpyaWVsQHJlZGhhdC5jb21dDQo+IFNlbnQ6IFR1ZXNkYXksIEp1bHkgMjYsIDIwMTYgMToxMiBQ
TQ0KPiBUbzoga2VybmVsLWhhcmRlbmluZ0BsaXN0cy5vcGVud2FsbC5jb207IGphc29uQGxha2Vk
YWVtb24ubmV0OyBsaW51eC0gDQo+IG1tQHZnZXIua2VybmVsLm9yZzsgbGludXgta2VybmVsQHZn
ZXIua2VybmVsLm9yZzsgYWtwbUBsaW51eC0gDQo+IGZvdW5kYXRpb24ub3JnDQo+IENjOiBrZWVz
Y29va0BjaHJvbWl1bS5vcmc7IGdyZWdraEBsaW51eGZvdW5kYXRpb24ub3JnOyBubmtAZ29vZ2xl
LmNvbTsgDQo+IGplZmZ2QGdvb2dsZS5jb207IHNhbHl6eW5AYW5kcm9pZC5jb207IGRjYXNobWFu
QGFuZHJvaWQuY29tOyBSb2JlcnRzLCANCj4gV2lsbGlhbSBDIDx3aWxsaWFtLmMucm9iZXJ0c0Bp
bnRlbC5jb20+DQo+IFN1YmplY3Q6IFJlOiBba2VybmVsLWhhcmRlbmluZ10gW1BBVENIXSBbUkZD
XSBJbnRyb2R1Y2UgbW1hcCANCj4gcmFuZG9taXphdGlvbg0KPiANCj4gT24gVHVlLCAyMDE2LTA3
LTI2IGF0IDExOjIyIC0wNzAwLCB3aWxsaWFtLmMucm9iZXJ0c0BpbnRlbC5jb20gd3JvdGU6DQo+
ID4gRnJvbTogV2lsbGlhbSBSb2JlcnRzIDx3aWxsaWFtLmMucm9iZXJ0c0BpbnRlbC5jb20+DQo+
ID4NCj4gPiBUaGlzIHBhdGNoIGludHJvZHVjZXMgdGhlIGFiaWxpdHkgcmFuZG9taXplIG1tYXAg
bG9jYXRpb25zIHdoZXJlIHRoZSANCj4gPiBhZGRyZXNzIGlzIG5vdCByZXF1ZXN0ZWQsIGZvciBp
bnN0YW5jZSB3aGVuIGxkIGlzIGFsbG9jYXRpbmcgcGFnZXMgDQo+ID4gZm9yIHNoYXJlZCBsaWJy
YXJpZXMuIEl0IGNob29zZXMgdG8gcmFuZG9taXplIGJhc2VkIG9uIHRoZSBjdXJyZW50IA0KPiA+
IHBlcnNvbmFsaXR5IGZvciBBU0xSLg0KPiA+DQo+ID4gQ3VycmVudGx5LCBhbGxvY2F0aW9ucyBh
cmUgZG9uZSBzZXF1ZW50aWFsbHkgd2l0aGluIHVubWFwcGVkIGFkZHJlc3MgDQo+ID4gc3BhY2Ug
Z2Fwcy4gVGhpcyBtYXkgaGFwcGVuIHRvcCBkb3duIG9yIGJvdHRvbSB1cCBkZXBlbmRpbmcgb24g
c2NoZW1lLg0KPiA+DQo+ID4gRm9yIGluc3RhbmNlIHRoZXNlIG1tYXAgY2FsbHMgcHJvZHVjZSBj
b250aWd1b3VzIG1hcHBpbmdzOg0KPiA+IGludCBzaXplID0gZ2V0cGFnZXNpemUoKTsNCj4gPiBt
bWFwKE5VTEwsIHNpemUsIGZsYWdzLCBNQVBfUFJJVkFURXxNQVBfQU5PTllNT1VTLCAtMSwgMCkg
PQ0KPiA+IDB4NDAwMjYwMDANCj4gPiBtbWFwKE5VTEwsIHNpemUsIGZsYWdzLCBNQVBfUFJJVkFU
RXxNQVBfQU5PTllNT1VTLCAtMSwgMCkgPQ0KPiA+IDB4NDAwMjcwMDANCj4gPg0KPiA+IE5vdGUg
bm8gZ2FwIGJldHdlZW4uDQo+ID4NCj4gPiBBZnRlciBwYXRjaGVzOg0KPiA+IGludCBzaXplID0g
Z2V0cGFnZXNpemUoKTsNCj4gPiBtbWFwKE5VTEwsIHNpemUsIGZsYWdzLCBNQVBfUFJJVkFURXxN
QVBfQU5PTllNT1VTLCAtMSwgMCkgPQ0KPiA+IDB4NDAwYjQwMDANCj4gPiBtbWFwKE5VTEwsIHNp
emUsIGZsYWdzLCBNQVBfUFJJVkFURXxNQVBfQU5PTllNT1VTLCAtMSwgMCkgPQ0KPiA+IDB4NDAw
NTUwMDANCj4gPg0KPiA+IE5vdGUgZ2FwIGJldHdlZW4uDQo+IA0KPiBJIHN1c3BlY3QgdGhpcyBy
YW5kb21pemF0aW9uIHdpbGwgYmUgbW9yZSB1c2VmdWwgZm9yIGZpbGUgbWFwcGluZ3MgDQo+IHRo
YW4gZm9yIGFub255bW91cyBtYXBwaW5ncy4NCj4gDQo+IEkgZG9uJ3Qga25vdyB3aGV0aGVyIHRo
ZXJlIGFyZSBkb3duc2lkZXMgdG8gY3JlYXRpbmcgbW9yZSBhbm9ueW1vdXMgDQo+IFZNQXMgdGhh
biB3ZSBoYXZlIHRvLCB3aXRoIG1hbGxvYyBsaWJyYXJpZXMgdGhhdCBtYXkgcGVyZm9ybSB2YXJp
b3VzIA0KPiBraW5kcyBvZiB0cmlja3Mgd2l0aCBtbWFwIGZvciB0aGVpciBvd24gcGVyZm9ybWFu
Y2UgcmVhc29ucy4NCj4gDQo+IERvZXMgYW55b25lIGhhdmUgY29udmluY2luZyByZWFzb25zIHdo
eSBtbWFwIHJhbmRvbWl6YXRpb24gc2hvdWxkIGRvIA0KPiBib3RoIGZpbGUgYW5kIGFub24sIG9y
IHdoZXRoZXIgaXQgc2hvdWxkIGRvIGp1c3QgZmlsZSBtYXBwaW5ncz8NCg0KVGhyb3dpbmcgdGhp
cyBvdXQgdGhlcmUsIGJ1dCBJZiB5b3UncmUgbW1hcCdpbmcgYnVmZmVycyBhdCBrbm93biBvZmZz
ZXRzIGluIHRoZQ0KcHJvZ3JhbSB0aGVuIGZvbGtzIGtub3cgd2hlcmUgdG8gd3JpdGUvbW9kaWZ5
Lg0KDQpKYXNvbiBDb29wZXIgbWVudGlvbmVkIHVzaW5nIGEgS0NvbmZpZyBhcm91bmQgdGhpcyAo
YW1vbmdzdCBvdGhlciB0aGluZ3MpIHdoaWNoIHBlcmhhcHMNCkNvbnRyb2xsaW5nIHRoaXMgYXQg
YSBiZXR0ZXIgZ3JhbnVsYXJpdHkgd291bGQgYmUgYmVuZWZpY2lhbC4NCg0KPiANCj4gLS0NCj4g
QWxsIHJpZ2h0cyByZXZlcnNlZA0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
