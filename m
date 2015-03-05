Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 846D16B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 03:18:04 -0500 (EST)
Received: by pdbfp1 with SMTP id fp1so13486045pdb.2
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 00:18:04 -0800 (PST)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id r8si8518207pap.44.2015.03.05.00.18.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Mar 2015 00:18:03 -0800 (PST)
Received: from tyo202.gate.nec.co.jp ([10.7.69.202])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t258I0ct002919
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Thu, 5 Mar 2015 17:18:00 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm: pagewalk: prevent positive return value of
 walk_page_test() from being passed to callers (Re: [PATCH] mm: fix do_mbind
 return value)
Date: Thu, 5 Mar 2015 08:09:49 +0000
Message-ID: <20150305080948.GB28441@hori1.linux.bs1.fc.nec.co.jp>
References: <54F7BD54.5060502@gmail.com>
 <alpine.DEB.2.10.1503042231250.15901@chino.kir.corp.google.com>
 <20150305080226.GA28441@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20150305080226.GA28441@hori1.linux.bs1.fc.nec.co.jp>
Content-Language: ja-JP
Content-Type: text/plain; charset="utf-8"
Content-ID: <DEC15EEF875C874E8DB90E9B73874ECE@gisp.nec.co.jp>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Kazutomo Yoshii <kazutomo.yoshii@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

T24gVGh1LCBNYXIgMDUsIDIwMTUgYXQgMDg6MDI6MjdBTSArMDAwMCwgSG9yaWd1Y2hpIE5hb3lh
KOWggOWPoyDnm7TkuZ8pIHdyb3RlOg0KLi4uDQo+IC0tLQ0KPiBGcm9tIDEwN2ZhM2ZiMjU2YmRk
ZmY0MGE4ODJjOTBhZjcxN2FmOTg2M2FlZDcgTW9uIFNlcCAxNyAwMDowMDowMCAyMDAxDQo+IEZy
b206IE5hb3lhIEhvcmlndWNoaSA8bi1ob3JpZ3VjaGlAYWguanAubmVjLmNvbT4NCj4gRGF0ZTog
VGh1LCA1IE1hciAyMDE1IDE2OjM3OjM3ICswOTAwDQo+IFN1YmplY3Q6IFtQQVRDSF0gbW06IHBh
Z2V3YWxrOiBwcmV2ZW50IHBvc2l0aXZlIHJldHVybiB2YWx1ZSBvZg0KPiAgd2Fsa19wYWdlX3Rl
c3QoKSBmcm9tIGJlaW5nIHBhc3NlZCB0byBjYWxsZXJzDQo+IA0KPiB3YWxrX3BhZ2VfdGVzdCgp
IGlzIHB1cmVseSBwYWdld2FsaydzIGludGVybmFsIHN0dWZmLCBhbmQgaXRzIHBvc2l0aXZlIHJl
dHVybg0KPiB2YWx1ZXMgYXJlIG5vdCBpbnRlbmRlZCB0byBiZSBwYXNzZWQgdG8gdGhlIGNhbGxl
cnMgb2YgcGFnZXdhbGsuIEhvd2V2ZXIsIGluDQo+IHRoZSBjdXJyZW50IGNvZGUgaWYgdGhlIGxh
c3Qgdm1hIGluIHRoZSBkby13aGlsZSBsb29wIGluIHdhbGtfcGFnZV9yYW5nZSgpDQo+IGhhcHBl
bnMgdG8gcmV0dXJuIGEgcG9zaXRpdmUgdmFsdWUsIGl0IGxlYWtzIG91dHNpZGUgd2Fsa19wYWdl
X3JhbmdlKCkuDQo+IFNvIHRoZSB1c2VyIHZpc2libGUgZWZmZWN0IGlzIGludmFsaWQvdW5leHBl
Y3RlZCByZXR1cm4gdmFsdWUgKGFjY29yZGluZyB0bw0KPiB0aGUgcmVwb3J0ZXIsIG1iaW5kKCkg
Y2F1c2VzIGl0LikNCj4gDQo+IFRoaXMgcGF0Y2ggZml4ZXMgaXQgc2ltcGx5IGJ5IHJlaW5pdGlh
bGl6aW5nIHRoZSByZXR1cm4gdmFsdWUgYWZ0ZXIgY2hlY2tlZC4NCj4gDQo+IEFub3RoZXIgZXhw
b3NlZCBpbnRlcmZhY2UsIHdhbGtfcGFnZV92bWEoKSwgYWxyZWFkeSByZXR1cm5zIDAgZm9yIHN1
Y2ggY2FzZXMNCj4gc28gbm8gcHJvYmxlbS4NCj4gDQo+IEZpeGVzOiA2ZjQ1NzZlMzY4N2IgKCJt
ZW1wb2xpY3k6IGFwcGx5IHBhZ2UgdGFibGUgd2Fsa2VyIG9uIHF1ZXVlX3BhZ2VzX3JhbmdlKCki
KQ0KDQpUaGlzIGlzIG5vdCBhIHJpZ2h0IHRhZy4gVG8gYmUgcHJlY2lzZSwgdGhlIGJ1ZyB3YXMg
aW50cm9kdWNlZCBieSBjb21taXQNCmZhZmFhNDI2NGViYSAoInBhZ2V3YWxrOiBpbXByb3ZlIHZt
YSBoYW5kbGluZyIpLCBzbw0KDQogIEZpeGVzIGZhZmFhNDI2NGViYSAoInBhZ2V3YWxrOiBpbXBy
b3ZlIHZtYSBoYW5kbGluZyIpDQoNCmlzIHJpZ2h0Lg0KDQpUaGFua3MsDQpOYW95YSBIb3JpZ3Vj
aGkNCg0KPiBSZXBvcnRlZC1ieTogS2F6dXRvbW8gWW9zaGlpIDxrYXp1dG9tby55b3NoaWlAZ21h
aWwuY29tPg0KPiBTaWduZWQtb2ZmLWJ5OiBOYW95YSBIb3JpZ3VjaGkgPG4taG9yaWd1Y2hpQGFo
LmpwLm5lYy5jb20+DQo+IC0tLQ0KPiAgbW0vcGFnZXdhbGsuYyB8IDkgKysrKysrKystDQo+ICAx
IGZpbGUgY2hhbmdlZCwgOCBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9uKC0pDQo+IA0KPiBkaWZm
IC0tZ2l0IGEvbW0vcGFnZXdhbGsuYyBiL21tL3BhZ2V3YWxrLmMNCj4gaW5kZXggNzVjMWYyODc4
NTE5Li4yOWYyZjhiODUzYWUgMTAwNjQ0DQo+IC0tLSBhL21tL3BhZ2V3YWxrLmMNCj4gKysrIGIv
bW0vcGFnZXdhbGsuYw0KPiBAQCAtMjY1LDggKzI2NSwxNSBAQCBpbnQgd2Fsa19wYWdlX3Jhbmdl
KHVuc2lnbmVkIGxvbmcgc3RhcnQsIHVuc2lnbmVkIGxvbmcgZW5kLA0KPiAgCQkJdm1hID0gdm1h
LT52bV9uZXh0Ow0KPiAgDQo+ICAJCQllcnIgPSB3YWxrX3BhZ2VfdGVzdChzdGFydCwgbmV4dCwg
d2Fsayk7DQo+IC0JCQlpZiAoZXJyID4gMCkNCj4gKwkJCWlmIChlcnIgPiAwKSB7DQo+ICsJCQkJ
LyoNCj4gKwkJCQkgKiBwb3NpdGl2ZSByZXR1cm4gdmFsdWVzIGFyZSBwdXJlbHkgZm9yDQo+ICsJ
CQkJICogY29udHJvbGxpbmcgdGhlIHBhZ2V3YWxrLCBzbyBzaG91bGQgbmV2ZXINCj4gKwkJCQkg
KiBiZSBwYXNzZWQgdG8gdGhlIGNhbGxlcnMuDQo+ICsJCQkJICovDQo+ICsJCQkJZXJyID0gMDsN
Cj4gIAkJCQljb250aW51ZTsNCj4gKwkJCX0NCj4gIAkJCWlmIChlcnIgPCAwKQ0KPiAgCQkJCWJy
ZWFrOw0KPiAgCQl9DQo+IC0tIA0KPiAxLjkuMw0KPiA=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
