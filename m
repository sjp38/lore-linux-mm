Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3069F6B5305
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 15:38:30 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id u13-v6so9713414qtb.18
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 12:38:30 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0115.outbound.protection.outlook.com. [104.47.34.115])
        by mx.google.com with ESMTPS id c27-v6si816052qtk.178.2018.08.30.12.38.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Aug 2018 12:38:29 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH RFCv2 5/6] powerpc/powernv: hold device_hotplug_lock in
 memtrace_offline_pages()
Date: Thu, 30 Aug 2018 19:38:26 +0000
Message-ID: <226aaaf7-7d1c-6f7b-5bf4-e6eb99862ebd@microsoft.com>
References: <20180821104418.12710-1-david@redhat.com>
 <20180821104418.12710-6-david@redhat.com>
In-Reply-To: <20180821104418.12710-6-david@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <22514313AC9ABF4BA9891A4203E5CEF8@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Rashmica Gupta <rashmica.g@gmail.com>, Balbir Singh <bsingharora@gmail.com>, Michael Neuling <mikey@neuling.org>

UmV2aWV3ZWQtYnk6IFBhdmVsIFRhdGFzaGluIDxwYXZlbC50YXRhc2hpbkBtaWNyb3NvZnQuY29t
Pg0KDQpPbiA4LzIxLzE4IDY6NDQgQU0sIERhdmlkIEhpbGRlbmJyYW5kIHdyb3RlOg0KPiBMZXQn
cyBwZXJmb3JtIGFsbCBjaGVja2luZyArIG9mZmxpbmluZyArIHJlbW92aW5nIHVuZGVyDQo+IGRl
dmljZV9ob3RwbHVnX2xvY2ssIHNvIG5vYm9keSBjYW4gbWVzcyB3aXRoIHRoZXNlIGRldmljZXMg
dmlhDQo+IHN5c2ZzIGNvbmN1cnJlbnRseS4NCj4gDQo+IENjOiBCZW5qYW1pbiBIZXJyZW5zY2ht
aWR0IDxiZW5oQGtlcm5lbC5jcmFzaGluZy5vcmc+DQo+IENjOiBQYXVsIE1hY2tlcnJhcyA8cGF1
bHVzQHNhbWJhLm9yZz4NCj4gQ2M6IE1pY2hhZWwgRWxsZXJtYW4gPG1wZUBlbGxlcm1hbi5pZC5h
dT4NCj4gQ2M6IFJhc2htaWNhIEd1cHRhIDxyYXNobWljYS5nQGdtYWlsLmNvbT4NCj4gQ2M6IEJh
bGJpciBTaW5naCA8YnNpbmdoYXJvcmFAZ21haWwuY29tPg0KPiBDYzogTWljaGFlbCBOZXVsaW5n
IDxtaWtleUBuZXVsaW5nLm9yZz4NCj4gU2lnbmVkLW9mZi1ieTogRGF2aWQgSGlsZGVuYnJhbmQg
PGRhdmlkQHJlZGhhdC5jb20+DQo+IC0tLQ0KPiAgYXJjaC9wb3dlcnBjL3BsYXRmb3Jtcy9wb3dl
cm52L21lbXRyYWNlLmMgfCAxMCArKysrKysrKy0tDQo+ICAxIGZpbGUgY2hhbmdlZCwgOCBpbnNl
cnRpb25zKCspLCAyIGRlbGV0aW9ucygtKQ0KPiANCj4gZGlmZiAtLWdpdCBhL2FyY2gvcG93ZXJw
Yy9wbGF0Zm9ybXMvcG93ZXJudi9tZW10cmFjZS5jIGIvYXJjaC9wb3dlcnBjL3BsYXRmb3Jtcy9w
b3dlcm52L21lbXRyYWNlLmMNCj4gaW5kZXggZWY3MTgxZDRmZTY4Li40NzNlNTk4NDJlYzUgMTAw
NjQ0DQo+IC0tLSBhL2FyY2gvcG93ZXJwYy9wbGF0Zm9ybXMvcG93ZXJudi9tZW10cmFjZS5jDQo+
ICsrKyBiL2FyY2gvcG93ZXJwYy9wbGF0Zm9ybXMvcG93ZXJudi9tZW10cmFjZS5jDQo+IEBAIC03
NCw5ICs3NCwxMyBAQCBzdGF0aWMgYm9vbCBtZW10cmFjZV9vZmZsaW5lX3BhZ2VzKHUzMiBuaWQs
IHU2NCBzdGFydF9wZm4sIHU2NCBucl9wYWdlcykNCj4gIHsNCj4gIAl1NjQgZW5kX3BmbiA9IHN0
YXJ0X3BmbiArIG5yX3BhZ2VzIC0gMTsNCj4gIA0KPiArCWxvY2tfZGV2aWNlX2hvdHBsdWcoKTsN
Cj4gKw0KPiAgCWlmICh3YWxrX21lbW9yeV9yYW5nZShzdGFydF9wZm4sIGVuZF9wZm4sIE5VTEws
DQo+IC0JICAgIGNoZWNrX21lbWJsb2NrX29ubGluZSkpDQo+ICsJICAgIGNoZWNrX21lbWJsb2Nr
X29ubGluZSkpIHsNCj4gKwkJdW5sb2NrX2RldmljZV9ob3RwbHVnKCk7DQo+ICAJCXJldHVybiBm
YWxzZTsNCj4gKwl9DQo+ICANCj4gIAl3YWxrX21lbW9yeV9yYW5nZShzdGFydF9wZm4sIGVuZF9w
Zm4sICh2b2lkICopTUVNX0dPSU5HX09GRkxJTkUsDQo+ICAJCQkgIGNoYW5nZV9tZW1ibG9ja19z
dGF0ZSk7DQo+IEBAIC04NCwxNCArODgsMTYgQEAgc3RhdGljIGJvb2wgbWVtdHJhY2Vfb2ZmbGlu
ZV9wYWdlcyh1MzIgbmlkLCB1NjQgc3RhcnRfcGZuLCB1NjQgbnJfcGFnZXMpDQo+ICAJaWYgKG9m
ZmxpbmVfcGFnZXMoc3RhcnRfcGZuLCBucl9wYWdlcykpIHsNCj4gIAkJd2Fsa19tZW1vcnlfcmFu
Z2Uoc3RhcnRfcGZuLCBlbmRfcGZuLCAodm9pZCAqKU1FTV9PTkxJTkUsDQo+ICAJCQkJICBjaGFu
Z2VfbWVtYmxvY2tfc3RhdGUpOw0KPiArCQl1bmxvY2tfZGV2aWNlX2hvdHBsdWcoKTsNCj4gIAkJ
cmV0dXJuIGZhbHNlOw0KPiAgCX0NCj4gIA0KPiAgCXdhbGtfbWVtb3J5X3JhbmdlKHN0YXJ0X3Bm
biwgZW5kX3BmbiwgKHZvaWQgKilNRU1fT0ZGTElORSwNCj4gIAkJCSAgY2hhbmdlX21lbWJsb2Nr
X3N0YXRlKTsNCj4gIA0KPiAtCXJlbW92ZV9tZW1vcnkobmlkLCBzdGFydF9wZm4gPDwgUEFHRV9T
SElGVCwgbnJfcGFnZXMgPDwgUEFHRV9TSElGVCk7DQo+ICsJX19yZW1vdmVfbWVtb3J5KG5pZCwg
c3RhcnRfcGZuIDw8IFBBR0VfU0hJRlQsIG5yX3BhZ2VzIDw8IFBBR0VfU0hJRlQpOw0KPiAgDQo+
ICsJdW5sb2NrX2RldmljZV9ob3RwbHVnKCk7DQo+ICAJcmV0dXJuIHRydWU7DQo+ICB9DQo+ICAN
Cj4g
