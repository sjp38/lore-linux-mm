Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 210848E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 12:45:15 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id a21-v6so2230440otf.8
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 09:45:15 -0700 (PDT)
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (mail-by2nam05on0605.outbound.protection.outlook.com. [2a01:111:f400:fe52::605])
        by mx.google.com with ESMTPS id q40-v6si6171864otg.210.2018.09.18.09.45.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 18 Sep 2018 09:45:13 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: Re: [PATCH 00/19] vmw_balloon: compaction, shrinker, 64-bit, etc.
Date: Tue, 18 Sep 2018 16:42:57 +0000
Message-ID: <B27D8BAC-28E2-4807-8D96-90A6938305F3@vmware.com>
References: <20180918063853.198332-1-namit@vmware.com>
 <20180918122729.GA13598@kroah.com>
In-Reply-To: <20180918122729.GA13598@kroah.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <A0DDE62851C5714E8E5C2F370CF0BEFA@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, LKML <linux-kernel@vger.kernel.org>, Xavier Deguillard <xdeguillard@vmware.com>, "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>

YXQgNToyNyBBTSwgR3JlZyBLcm9haC1IYXJ0bWFuIDxncmVna2hAbGludXhmb3VuZGF0aW9uLm9y
Zz4gd3JvdGU6DQoNCj4gT24gTW9uLCBTZXAgMTcsIDIwMTggYXQgMTE6Mzg6MzRQTSAtMDcwMCwg
TmFkYXYgQW1pdCB3cm90ZToNCj4+IFRoaXMgcGF0Y2gtc2V0IGFkZHMgdGhlIGZvbGxvd2luZyBl
bmhhbmNlbWVudHMgdG8gdGhlIFZNd2FyZSBiYWxsb29uDQo+PiBkcml2ZXI6DQo+PiANCj4+IDEu
IEJhbGxvb24gY29tcGFjdGlvbiBzdXBwb3J0Lg0KPj4gMi4gUmVwb3J0IHRoZSBudW1iZXIgb2Yg
aW5mbGF0ZWQvZGVmbGF0ZWQgYmFsbG9vbmVkIHBhZ2VzIHRocm91Z2ggdm1zdGF0Lg0KPj4gMy4g
TWVtb3J5IHNocmlua2VyIHRvIGF2b2lkIGJhbGxvb24gb3Zlci1pbmZsYXRpb24gKGFuZCBPT00p
Lg0KPj4gNC4gU3VwcG9ydCBWTXMgd2l0aCBtZW1vcnkgbGltaXQgdGhhdCBpcyBncmVhdGVyIHRo
YW4gMTZUQi4NCj4+IDUuIEZhc3RlciBhbmQgbW9yZSBhZ2dyZXNzaXZlIGluZmxhdGlvbi4NCj4+
IA0KPj4gVG8gc3VwcG9ydCBjb21wYWN0aW9uIHdlIHdpc2ggdG8gdXNlIHRoZSBleGlzdGluZyBp
bmZyYXN0cnVjdHVyZS4NCj4+IEhvd2V2ZXIsIHdlIG5lZWQgdG8gbWFrZSBzbGlnaHQgYWRhcHRp
b25zIGZvciBpdC4gV2UgYWRkIGEgbmV3IGxpc3QNCj4+IGludGVyZmFjZSB0byBiYWxsb29uLWNv
bXBhY3Rpb24sIHdoaWNoIGlzIG1vcmUgZ2VuZXJpYyBhbmQgZWZmaWNpZW50LA0KPj4gc2luY2Ug
aXQgZG9lcyBub3QgcmVxdWlyZSBhcyBtYW55IElSUSBzYXZlL3Jlc3RvcmUgb3BlcmF0aW9ucy4g
V2UgbGVhdmUNCj4+IHRoZSBvbGQgaW50ZXJmYWNlIHRoYXQgaXMgdXNlZCBieSB0aGUgdmlydGlv
IGJhbGxvb24uDQo+PiANCj4+IEJpZyBwYXJ0cyBvZiB0aGlzIHBhdGNoLXNldCBhcmUgY2xlYW51
cCBhbmQgZG9jdW1lbnRhdGlvbi4gUGF0Y2hlcyAxLTEzDQo+PiBzaW1wbGlmeSB0aGUgYmFsbG9v
biBjb2RlLCBkb2N1bWVudCBpdHMgYmVoYXZpb3IgYW5kIGFsbG93IHRoZSBiYWxsb29uDQo+PiBj
b2RlIHRvIHJ1biBjb25jdXJyZW50bHkuIFRoZSBzdXBwb3J0IGZvciBjb25jdXJyZW5jeSBpcyBy
ZXF1aXJlZCBmb3INCj4+IGNvbXBhY3Rpb24gYW5kIHRoZSBzaHJpbmtlciBpbnRlcmZhY2UuDQo+
PiANCj4+IEZvciBkb2N1bWVudGF0aW9uIHdlIHVzZSB0aGUga2VybmVsLWRvYyBmb3JtYXQuIFdl
IGFyZSBhd2FyZSB0aGF0IHRoZQ0KPj4gYmFsbG9vbiBpbnRlcmZhY2UgaXMgbm90IHB1YmxpYywg
YnV0IGZvbGxvd2luZyB0aGUga2VybmVsLWRvYyBmb3JtYXQgbWF5DQo+PiBiZSB1c2VmdWwgb25l
IGRheS4NCj4gDQo+IGtidWlsZCBzZWVtcyB0byBub3QgbGlrZSB0aGlzIHBhdGNoIHNlcmllcywg
c28gSSdtIGdvaW5nIHRvIGRyb3AgaXQgZnJvbQ0KPiBteSBxdWV1ZSBhbmQgd2FpdCBmb3IgYSB2
MiByZXNwaW4gYmVmb3JlIGxvb2tpbmcgYXQgaXQuDQoNClN1cmUuIEnigJlsbCBzZW5kIHYyIGlu
IGEgZGF5IG9yIHR3by4NCg0KTmFkYXYgDQoNCg0K
