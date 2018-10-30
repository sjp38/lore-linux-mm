Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 750E96B0375
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 12:32:26 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id h138-v6so10032964oic.21
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 09:32:26 -0700 (PDT)
Received: from NAM05-CO1-obe.outbound.protection.outlook.com (mail-eopbgr720067.outbound.protection.outlook.com. [40.107.72.67])
        by mx.google.com with ESMTPS id 94si11066419otd.48.2018.10.30.09.32.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 Oct 2018 09:32:25 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: Re: [PATCH v3 00/20] vmw_balloon: compaction, shrinker, 64-bit, etc.
Date: Tue, 30 Oct 2018 16:32:22 +0000
Message-ID: <E1B69BF2-458D-435C-8065-6944111A9EC6@vmware.com>
References: <20180926191336.101885-1-namit@vmware.com>
In-Reply-To: <20180926191336.101885-1-namit@vmware.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <BB8410277155E24686666DFA454A1F55@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Cc: Xavier Deguillard <xdeguillard@vmware.com>, LKML <linux-kernel@vger.kernel.org>, "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>

RnJvbTogTmFkYXYgQW1pdA0KU2VudDogU2VwdGVtYmVyIDI2LCAyMDE4IGF0IDc6MTM6MTYgUE0g
R01UDQo+IFRvOiBBcm5kIEJlcmdtYW5uIDxhcm5kQGFybmRiLmRlPiwgZ3JlZ2toQGxpbnV4Zm91
bmRhdGlvbi5vcmcNCj4gQ2M6IFhhdmllciBEZWd1aWxsYXJkIDx4ZGVndWlsbGFyZEB2bXdhcmUu
Y29tPiwgbGludXgta2VybmVsQHZnZXIua2VybmVsLm9yZz4sIE5hZGF2IEFtaXQgPG5hbWl0QHZt
d2FyZS5jb20+LCBNaWNoYWVsIFMuIFRzaXJraW4gPG1zdEByZWRoYXQuY29tPiwgSmFzb24gV2Fu
ZyA8amFzb3dhbmdAcmVkaGF0LmNvbT4sIGxpbnV4LW1tQGt2YWNrLm9yZz4sIHZpcnR1YWxpemF0
aW9uQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnDQo+IFN1YmplY3Q6IFtQQVRDSCB2MyAwMC8y
MF0gdm13X2JhbGxvb246IGNvbXBhY3Rpb24sIHNocmlua2VyLCA2NC1iaXQsIGV0Yy4NCj4gDQo+
IA0KPiBUaGlzIHBhdGNoLXNldCBhZGRzIHRoZSBmb2xsb3dpbmcgZW5oYW5jZW1lbnRzIHRvIHRo
ZSBWTXdhcmUgYmFsbG9vbg0KPiBkcml2ZXI6DQo+IA0KPiAxLiBCYWxsb29uIGNvbXBhY3Rpb24g
c3VwcG9ydC4NCj4gMi4gUmVwb3J0IHRoZSBudW1iZXIgb2YgaW5mbGF0ZWQvZGVmbGF0ZWQgYmFs
bG9vbmVkIHBhZ2VzIHRocm91Z2ggdm1zdGF0Lg0KPiAzLiBNZW1vcnkgc2hyaW5rZXIgdG8gYXZv
aWQgYmFsbG9vbiBvdmVyLWluZmxhdGlvbiAoYW5kIE9PTSkuDQo+IDQuIFN1cHBvcnQgVk1zIHdp
dGggbWVtb3J5IGxpbWl0IHRoYXQgaXMgZ3JlYXRlciB0aGFuIDE2VEIuDQo+IDUuIEZhc3RlciBh
bmQgbW9yZSBhZ2dyZXNzaXZlIGluZmxhdGlvbi4NCj4gDQo+IFRvIHN1cHBvcnQgY29tcGFjdGlv
biB3ZSB3aXNoIHRvIHVzZSB0aGUgZXhpc3RpbmcgaW5mcmFzdHJ1Y3R1cmUuDQo+IEhvd2V2ZXIs
IHdlIG5lZWQgdG8gbWFrZSBzbGlnaHQgYWRhcHRpb25zIGZvciBpdC4gV2UgYWRkIGEgbmV3IGxp
c3QNCj4gaW50ZXJmYWNlIHRvIGJhbGxvb24tY29tcGFjdGlvbiwgd2hpY2ggaXMgbW9yZSBnZW5l
cmljIGFuZCBlZmZpY2llbnQsDQo+IHNpbmNlIGl0IGRvZXMgbm90IHJlcXVpcmUgYXMgbWFueSBJ
UlEgc2F2ZS9yZXN0b3JlIG9wZXJhdGlvbnMuIFdlIGxlYXZlDQo+IHRoZSBvbGQgaW50ZXJmYWNl
IHRoYXQgaXMgdXNlZCBieSB0aGUgdmlydGlvIGJhbGxvb24uDQo+IA0KPiBCaWcgcGFydHMgb2Yg
dGhpcyBwYXRjaC1zZXQgYXJlIGNsZWFudXAgYW5kIGRvY3VtZW50YXRpb24uIFBhdGNoZXMgMS0x
Mw0KPiBzaW1wbGlmeSB0aGUgYmFsbG9vbiBjb2RlLCBkb2N1bWVudCBpdHMgYmVoYXZpb3IgYW5k
IGFsbG93IHRoZSBiYWxsb29uDQo+IGNvZGUgdG8gcnVuIGNvbmN1cnJlbnRseS4gVGhlIHN1cHBv
cnQgZm9yIGNvbmN1cnJlbmN5IGlzIHJlcXVpcmVkIGZvcg0KPiBjb21wYWN0aW9uIGFuZCB0aGUg
c2hyaW5rZXIgaW50ZXJmYWNlLg0KPiANCj4gRm9yIGRvY3VtZW50YXRpb24gd2UgdXNlIHRoZSBr
ZXJuZWwtZG9jIGZvcm1hdC4gV2UgYXJlIGF3YXJlIHRoYXQgdGhlDQo+IGJhbGxvb24gaW50ZXJm
YWNlIGlzIG5vdCBwdWJsaWMsIGJ1dCBmb2xsb3dpbmcgdGhlIGtlcm5lbC1kb2MgZm9ybWF0IG1h
eQ0KPiBiZSB1c2VmdWwgb25lIGRheS4NCj4gDQo+IHYyLT52MzogKiBNb3ZpbmcgdGhlIGJhbGxv
b24gbWFnaWMtbnVtYmVyIG91dCBvZiB1YXBpIChHcmVnKQ0KPiANCj4gdjEtPnYyOgkqIEZpeCBi
dWlsZCBlcnJvciB3aGVuIFRIUCBpcyBvZmYgKGtidWlsZCkNCj4gCSogRml4IGJ1aWxkIGVycm9y
IG9uIGkzODYgKGtidWlsZCkNCj4gDQoNCkdyZWcsDQoNCkkgcmVhbGl6ZSB5b3UgZGlkbuKAmXQg
YXBwbHkgcGF0Y2hlcyAxNy0yMC4gQW55IHJlYXNvbiBmb3IgdGhhdD8NCg0KVGhhbmtzLA0KTmFk
YXYNCg0KDQo=
