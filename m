Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id ECBAD6B0257
	for <linux-mm@kvack.org>; Sun,  9 Aug 2015 20:53:04 -0400 (EDT)
Received: by pdbfa8 with SMTP id fa8so24945372pdb.1
        for <linux-mm@kvack.org>; Sun, 09 Aug 2015 17:53:04 -0700 (PDT)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id ka15si30299471pbb.176.2015.08.09.17.53.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 09 Aug 2015 17:53:04 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp ([10.7.69.201])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t7A0r0T3020273
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 09:53:01 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 2/2] mm: hugetlb: add VmHugetlbRSS: field in
 /proc/pid/status
Date: Mon, 10 Aug 2015 00:47:08 +0000
Message-ID: <1439167624-17772-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <20150807155537.d483456f753355059f9ce10a@linux-foundation.org>
In-Reply-To: <20150807155537.d483456f753355059f9ce10a@linux-foundation.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, =?utf-8?B?SsO2cm4gRW5nZWw=?= <joern@purestorage.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

T24gRnJpLCBBdWcgMDcsIDIwMTUgYXQgMDM6NTU6MzdQTSAtMDcwMCwgQW5kcmV3IE1vcnRvbiB3
cm90ZToNCj4gT24gRnJpLCA3IEF1ZyAyMDE1IDA3OjI0OjUwICswMDAwIE5hb3lhIEhvcmlndWNo
aSA8bi1ob3JpZ3VjaGlAYWguanAubmVjLmNvbT4gd3JvdGU6DQo+IA0KPiA+IEN1cnJlbnRseSB0
aGVyZSdzIG5vIGVhc3kgd2F5IHRvIGdldCBwZXItcHJvY2VzcyB1c2FnZSBvZiBodWdldGxiIHBh
Z2VzLCB3aGljaA0KPiA+IGlzIGluY29udmVuaWVudCBiZWNhdXNlIGFwcGxpY2F0aW9ucyB3aGlj
aCB1c2UgaHVnZXRsYiB0eXBpY2FsbHkgd2FudCB0byBjb250cm9sDQo+ID4gdGhlaXIgcHJvY2Vz
c2VzIG9uIHRoZSBiYXNpcyBvZiBob3cgbXVjaCBtZW1vcnkgKGluY2x1ZGluZyBodWdldGxiKSB0
aGV5IHVzZS4NCj4gPiBTbyB0aGlzIHBhdGNoIHNpbXBseSBwcm92aWRlcyBlYXN5IGFjY2VzcyB0
byB0aGUgaW5mbyB2aWEgL3Byb2MvcGlkL3N0YXR1cy4NCj4gPiANCj4gPiBUaGlzIHBhdGNoIHNo
b3VsZG4ndCBjaGFuZ2UgdGhlIE9PTSBiZWhhdmlvciAoc28gaHVnZXRsYiB1c2FnZSBpcyBpZ25v
cmVkIGFzDQo+ID4gaXMgbm93LCkgd2hpY2ggSSBndWVzcyBpcyBmaW5lIHVudGlsIHdlIGhhdmUg
c29tZSBzdHJvbmcgcmVhc29uIHRvIGRvIGl0Lg0KPiA+IA0KPiANCj4gQSBwcm9jZnMgY2hhbmdl
IHRyaWdnZXJzIGEgZG9jdW1lbnRhdGlvbiBjaGFuZ2UuICBBbHdheXMsIHBsZWFzZS4gDQo+IERv
Y3VtZW50YXRpb24vZmlsZXN5c3RlbXMvcHJvYy50eHQgaXMgdGhlIHBsYWNlLg0KDQpPSywgSSds
bCBkbyB0aGlzLg0KDQo+ID4NCj4gPiAuLi4NCj4gPg0KPiA+IEBAIC01MDQsNiArNTE5LDkgQEAg
c3RhdGljIGlubGluZSBzcGlubG9ja190ICpodWdlX3B0ZV9sb2NrcHRyKHN0cnVjdCBoc3RhdGUg
KmgsDQo+ID4gIHsNCj4gPiAgCXJldHVybiAmbW0tPnBhZ2VfdGFibGVfbG9jazsNCj4gPiAgfQ0K
PiA+ICsNCj4gPiArI2RlZmluZSBnZXRfaHVnZXRsYl9yc3MobW0pCTANCj4gPiArI2RlZmluZSBt
b2RfaHVnZXRsYl9yc3MobW0sIHZhbHVlKQlkbyB7fSB3aGlsZSAoMCkNCj4gDQo+IEkgZG9uJ3Qg
dGhpbmsgdGhlc2UgaGF2ZSB0byBiZSBtYWNyb3M/ICBpbmxpbmUgZnVuY3Rpb25zIGFyZSBuaWNl
ciBpbg0KPiBzZXZlcmFsIHdheXM6IG1vcmUgcmVhZGFibGUsIG1vcmUgbGlrZWx5IHRvIGJlIGRv
Y3VtZW50ZWQsIGNhbiBwcmV2ZW50DQo+IHVudXNlZCB2YXJpYWJsZSB3YXJuaW5ncy4NCg0KUmln
aHQsIEknbGwgdXNlIGlubGluZSBmdW5jdGlvbnMuDQoNCj4gPiAgI2VuZGlmCS8qIENPTkZJR19I
VUdFVExCX1BBR0UgKi8NCj4gPiAgDQo+ID4gIHN0YXRpYyBpbmxpbmUgc3BpbmxvY2tfdCAqaHVn
ZV9wdGVfbG9jayhzdHJ1Y3QgaHN0YXRlICpoLA0KPiA+DQo+ID4gLi4uDQo+ID4NCj4gPiAtLS0g
djQuMi1yYzQub3JpZy9tbS9tZW1vcnkuYw0KPiA+ICsrKyB2NC4yLXJjNC9tbS9tZW1vcnkuYw0K
PiA+IEBAIC02MjAsMTIgKzYyMCwxMiBAQCBpbnQgX19wdGVfYWxsb2Nfa2VybmVsKHBtZF90ICpw
bWQsIHVuc2lnbmVkIGxvbmcgYWRkcmVzcykNCj4gPiAgCXJldHVybiAwOw0KPiA+ICB9DQo+ID4g
IA0KPiA+IC1zdGF0aWMgaW5saW5lIHZvaWQgaW5pdF9yc3NfdmVjKGludCAqcnNzKQ0KPiA+ICtp
bmxpbmUgdm9pZCBpbml0X3Jzc192ZWMoaW50ICpyc3MpDQo+ID4gIHsNCj4gPiAgCW1lbXNldChy
c3MsIDAsIHNpemVvZihpbnQpICogTlJfTU1fQ09VTlRFUlMpOw0KPiA+ICB9DQo+ID4gIA0KPiA+
IC1zdGF0aWMgaW5saW5lIHZvaWQgYWRkX21tX3Jzc192ZWMoc3RydWN0IG1tX3N0cnVjdCAqbW0s
IGludCAqcnNzKQ0KPiA+ICtpbmxpbmUgdm9pZCBhZGRfbW1fcnNzX3ZlYyhzdHJ1Y3QgbW1fc3Ry
dWN0ICptbSwgaW50ICpyc3MpDQo+ID4gIHsNCj4gPiAgCWludCBpOw0KPiANCj4gVGhlIGlubGlu
ZXMgYXJlIGEgYml0IG9kZCwgYnV0IHRoaXMgZG9lcyBzYXZlIH4xMCBieXRlcyBpbiBtZW1vcnku
byBmb3INCj4gc29tZSByZWFzb24uDQoNCnNvIEknbGwga2VlcCBnb2luZyB3aXRoIHRoaXMuDQoN
ClRoYW5rcywNCk5hb3lhIEhvcmlndWNoaQ==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
