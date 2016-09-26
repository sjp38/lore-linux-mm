Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7DBEA6B0273
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 11:05:50 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id s64so97562644lfs.1
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 08:05:50 -0700 (PDT)
Received: from smtp-out6.electric.net (smtp-out6.electric.net. [192.162.217.181])
        by mx.google.com with ESMTPS id x195si8715322lff.227.2016.09.26.08.05.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 08:05:48 -0700 (PDT)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] fs/select: add vmalloc fallback for select(2)
Date: Mon, 26 Sep 2016 15:02:50 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0109D2D@AcuExch.aculab.com>
References: <20160922164359.9035-1-vbabka@suse.cz>
 <1474562982.23058.140.camel@edumazet-glaptop3.roam.corp.google.com>
 <12efc491-a0e7-1012-5a8b-6d3533c720db@suse.cz>
 <1474564068.23058.144.camel@edumazet-glaptop3.roam.corp.google.com>
 <a212f313-1f34-7c83-3aab-b45374875493@suse.cz>
 <063D6719AE5E284EB5DD2968C1650D6DB0107DC8@AcuExch.aculab.com>
 <3bbcc269-ec8b-12dd-e0ae-190c18bc3f47@suse.cz>
 <063D6719AE5E284EB5DD2968C1650D6DB0107FEB@AcuExch.aculab.com>
 <5bb958c9-542e-e86b-779c-e3d93dc01632@suse.cz>
In-Reply-To: <5bb958c9-542e-e86b-779c-e3d93dc01632@suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Vlastimil Babka' <vbabka@suse.cz>, Eric Dumazet <eric.dumazet@gmail.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, "linux-man@vger.kernel.org" <linux-man@vger.kernel.org>

RnJvbTogVmxhc3RpbWlsIEJhYmthDQo+IFNlbnQ6IDI2IFNlcHRlbWJlciAyMDE2IDExOjAyDQo+
IE9uIDA5LzIzLzIwMTYgMDM6MzUgUE0sIERhdmlkIExhaWdodCB3cm90ZToNCj4gPiBGcm9tOiBW
bGFzdGltaWwgQmFia2ENCj4gPj4gU2VudDogMjMgU2VwdGVtYmVyIDIwMTYgMTA6NTkNCj4gPiAu
Li4NCj4gPj4gPiBJIHN1c3BlY3QgdGhhdCBmZHQtPm1heF9mZHMgaXMgYW4gdXBwZXIgYm91bmQg
Zm9yIHRoZSBoaWdoZXN0IGZkIHRoZQ0KPiA+PiA+IHByb2Nlc3MgaGFzIG9wZW4gLSBub3QgdGhl
IFJMSU1JVF9OT0ZJTEUgdmFsdWUuDQo+ID4+DQo+ID4+IEkgZ2F0aGVyZWQgdGhhdCB0aGUgaGln
aGVzdCBmZCBlZmZlY3RpdmVseSBsaW1pdHMgdGhlIG51bWJlciBvZiBmaWxlcywNCj4gPj4gc28g
aXQncyB0aGUgc2FtZS4gSSBtaWdodCBiZSB3cm9uZy4NCj4gPg0KPiA+IEFuIGFwcGxpY2F0aW9u
IGNhbiByZWR1Y2UgUkxJTUlUX05PRklMRSBiZWxvdyB0aGF0IG9mIGFuIG9wZW4gZmlsZS4NCj4g
DQo+IE9LLCBJIGRpZCBzb21lIG1vcmUgZGlnZ2luZyBpbiB0aGUgY29kZSwgYW5kIG15IHVuZGVy
c3RhbmRpbmcgaXMgdGhhdDoNCj4gDQo+IC0gZmR0LT5tYXhfZmRzIGlzIHRoZSBjdXJyZW50IHNp
emUgb2YgdGhlIGZkdGFibGUsIHdoaWNoIGlzbid0IGFsbG9jYXRlZCB1cGZyb250DQo+IHRvIG1h
dGNoIHRoZSBsaW1pdCwgYnV0IGdyb3dzIGFzIG5lZWRlZC4gVGhpcyBtZWFucyBpdCdzIE9LIGZv
cg0KPiBjb3JlX3N5c19zZWxlY3QoKSB0byBzaWxlbnRseSBjYXAgbmZkcywgYXMgaXQga25vd3Mg
dGhlcmUgYXJlIG5vIGZkJ3Mgd2l0aA0KPiBoaWdoZXIgbnVtYmVyIGluIHRoZSBmZHRhYmxlLCBz
byBpdCdzIGEgcGVyZm9ybWFuY2Ugb3B0aW1pemF0aW9uLg0KDQpOb3QgZW50aXJlbHksIGlmIGFu
eSBiaXRzIGFyZSBzZXQgZm9yIGZkIGFib3ZlIGZkdC0+bWF4X2ZkcyB0aGVuIHNlbGVjdCgpDQpj
YWxsIHNob3VsZCBmYWlsIC0gZmQgbm90IG9wZW4uDQoNCj4gSG93ZXZlciwgdG8NCj4gbWF0Y2gg
d2hhdCB0aGUgbWFucGFnZSBzYXlzLCB0aGVyZSBzaG91bGQgYmUgYW5vdGhlciBjaGVjayBhZ2Fp
bnN0IFJMSU1JVF9OT0ZJTEUNCj4gdG8gcmV0dXJuIC1FSU5WQUwsIHdoaWNoIHRoZXJlIGlzbid0
LCBBRkFJQ1MuDQo+IA0KPiAtIGZkdGFibGUgaXMgZXhwYW5kZWQgKGFuZCBmZHQtPm1heF9mZHMg
YnVtcGVkKSBieQ0KPiBleHBhbmRfZmlsZXMoKS0+ZXhwYW5kX2ZkdGFibGUoKSB3aGljaCBjaGVj
a3MgYWdhaW5zdCBmcy5ucl9vcGVuIHN5c2N0bCwgd2hpY2gNCj4gc2VlbXMgdG8gYmUgMTA0ODU3
NiB3aGVyZSBJIGNoZWNrZWQuDQo+IA0KPiAtIGNhbGxlcnMgb2YgZXhwYW5kX2ZpbGVzKCksIHN1
Y2ggYXMgZHVwKCksIGNoZWNrIHRoZSBybGltaXQoUkxJTUlUX05PRklMRSkgdG8NCj4gbGltaXQg
dGhlIGV4cGFuc2lvbi4NCj4gDQo+IFNvIHllYWgsIGFwcGxpY2F0aW9uIGNhbiByZWR1Y2UgUkxJ
TUlUX05PRklMRSwgYnV0IGl0IGhhcyBubyBlZmZlY3Qgb24gZmR0YWJsZQ0KPiBhbmQgZmR0LT5t
YXhfZmRzIHRoYXQgaXMgYWxyZWFkeSBhYm92ZSB0aGUgbGltaXQuIFNlbGVjdCBzeXNjYWxsIHdv
dWxkIGhhdmUgdG8NCj4gY2hlY2sgdGhlIHJsaW1pdCB0byBjb25mb3JtIHRvIHRoZSBtYW5wYWdl
LiBPciAocmF0aGVyPykgd2Ugc2hvdWxkIGZpeCB0aGUgbWFucGFnZS4NCg0KSSB0aGluayB0aGUg
bWFucGFnZSBzaG91bGQgYmUgZml4ZWQgKGRlbGV0ZSB0aGF0IGNsYXVzZSkuDQpUaGVuIGFkZCBj
b2RlIHRvIHRoZSBzeXN0ZW0gY2FsbCB0byBzY2FuIHRoZSBoaWdoIGJpdCBzZXRzIChhYm92ZSBm
ZHQtPm1heF9mZHMpDQpmb3IgYW55IG5vbi16ZXJvIGJ5dGVzLiBUaGlzIGNhbiBiZSBkb25lIGlu
dG8gYSBzbWFsbCBidWZmZXIuDQoNCj4gQXMgZm9yIHRoZSBvcmlnaW5hbCB2bWFsbG9jKCkgZmxv
b2QgY29uY2VybiwgSSBzdGlsbCB0aGluayB3ZSdyZSBzYWZlLCBhcw0KPiBvcmRpbmFyeSB1c2Vy
cyBhcmUgbGltaXRlZCBieSBSTElNSVRfTk9GSUxFIHdheSBiZWxvdyBzaXplcyB0aGF0IHdvdWxk
IG5lZWQNCj4gdm1hbGxvYygpLCBhbmQgcm9vdCBoYXMgbWFueSBvdGhlciBvcHRpb25zIHRvIERP
UyB0aGUgc3lzdGVtIChvciB3b3JzZSkuDQoNClNvbWUgcHJvY2Vzc2VzIG5lZWQgdmVyeSBoaWdo
IG51bWJlcnMgb2YgZmQuDQpMaWtlbHkgdGhleSBkb24ndCB1c2Ugc2VsZWN0KCkgb24gdGhlbSwg
YnV0IHRyYXNoaW5nIHBlcmZvcm1hbmNlIGlmIHRoZXkNCmRvIGlzIGEgYml0IHNpbGx5Lg0KVHJ5
aW5nIHRvIHNsaXQgdGhlIDMgbWFza3MgZmlyc3Qgc2VlbXMgc2Vuc2libGUuDQoNCglEYXZpZA0K
DQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
