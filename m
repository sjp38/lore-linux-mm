Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D8106280263
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 18:57:51 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id p1so12793415pfp.13
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 15:57:51 -0800 (PST)
Received: from esa4.hgst.iphmx.com (esa4.hgst.iphmx.com. [216.71.154.42])
        by mx.google.com with ESMTPS id a30si2573838pgn.599.2018.01.16.15.57.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 15:57:50 -0800 (PST)
From: Bart Van Assche <Bart.VanAssche@wdc.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] A high-performance userspace block driver
Date: Tue, 16 Jan 2018 23:57:45 +0000
Message-ID: <1516147064.2844.66.camel@wdc.com>
References: <20180116145240.GD30073@bombadil.infradead.org>
	 <20180116232335.GM8249@thunk.org>
	 <1516145316.14734.11.camel@HansenPartnership.com>
In-Reply-To: <1516145316.14734.11.camel@HansenPartnership.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <DA11E7A12C88BB43A3F1AEC8A1C1EE0B@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "James.Bottomley@HansenPartnership.com" <James.Bottomley@HansenPartnership.com>, "tytso@mit.edu" <tytso@mit.edu>, "willy@infradead.org" <willy@infradead.org>
Cc: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

T24gVHVlLCAyMDE4LTAxLTE2IGF0IDE1OjI4IC0wODAwLCBKYW1lcyBCb3R0b21sZXkgd3JvdGU6
DQo+IE9uIFR1ZSwgMjAxOC0wMS0xNiBhdCAxODoyMyAtMDUwMCwgVGhlb2RvcmUgVHMnbyB3cm90
ZToNCj4gPiBPbiBUdWUsIEphbiAxNiwgMjAxOCBhdCAwNjo1Mjo0MEFNIC0wODAwLCBNYXR0aGV3
IFdpbGNveCB3cm90ZToNCj4gPiA+IA0KPiA+ID4gDQo+ID4gPiBJIHNlZSB0aGUgaW1wcm92ZW1l
bnRzIHRoYXQgRmFjZWJvb2sgaGF2ZSBiZWVuIG1ha2luZyB0byB0aGUgbmJkDQo+ID4gPiBkcml2
ZXIsIGFuZCBJIHRoaW5rIHRoYXQncyBhIHdvbmRlcmZ1bCB0aGluZy4gIE1heWJlIHRoZSBvdXRj
b21lIG9mDQo+ID4gPiB0aGlzIHRvcGljIGlzIHNpbXBseTogIlNodXQgdXAsIE1hdHRoZXcsIHRo
aXMgaXMgZ29vZCBlbm91Z2giLg0KPiA+ID4gDQo+ID4gPiBJdCdzIGNsZWFyIHRoYXQgdGhlcmUn
cyBhbiBhcHBldGl0ZSBmb3IgdXNlcnNwYWNlIGJsb2NrIGRldmljZXM7DQo+ID4gPiBub3QgZm9y
IHN3YXAgZGV2aWNlcyBvciB0aGUgcm9vdCBkZXZpY2UsIGJ1dCBmb3IgYWNjZXNzaW5nIGRhdGEN
Cj4gPiA+IHRoYXQncyBzdG9yZWQgaW4gdGhhdCBzaWxvIG92ZXIgdGhlcmUsIGFuZCBJIHJlYWxs
eSBkb24ndCB3YW50IHRvDQo+ID4gPiBicmluZyB0aGF0IGVudGlyZSBtZXNzIG9mIENPUkJBIC8g
R28gLyBSdXN0IC8gd2hhdGV2ZXIgaW50byB0aGUNCj4gPiA+IGtlcm5lbCB0byBnZXQgdG8gaXQs
IGJ1dCBpdCB3b3VsZCBiZSByZWFsbHkgaGFuZHkgdG8gcHJlc2VudCBpdCBhcw0KPiA+ID4gYSBi
bG9jayBkZXZpY2UuDQo+ID4gDQo+ID4gLi4uIGFuZCB1c2luZyBpU0NTSSB3YXMgdG9vIHBhaW5m
dWwgYW5kIGhlYXZ5d2VpZ2h0Lg0KPiANCj4gRnJvbSB3aGF0IEkndmUgc2VlbiBhIHJlYXNvbmFi
bGUgbnVtYmVyIG9mIHN0b3JhZ2Ugb3ZlciBJUCBjbG91ZA0KPiBpbXBsZW1lbnRhdGlvbnMgYXJl
IGFjdHVhbGx5IHVzaW5nIEFvRS4gIFRoZSBhcmd1bWVudCBnb2VzIHRoYXQgdGhlDQo+IHByb3Rv
Y29sIGlzIGFib3V0IGlkZWFsIChhdCBsZWFzdCBhcyBjb21wYXJlZCB0byBpU0NTSSBvciBGQ29F
KSBhbmQgdGhlDQo+IGNvbXBhbnkgYmVoaW5kIGl0IGRvZXNuJ3Qgc2VlbSB0byB3YW50IHRvIGFk
ZCBhbnkgbW9yZSBmZWF0dXJlcyB0aGF0DQo+IHdvdWxkIGJsb2F0IGl0Lg0KDQpIYXMgYW55b25l
IGFscmVhZHkgbG9va2VkIGludG8gaVNFUiwgU1JQIG9yIE5WTWVPRiBvdmVyIHJkbWFfcnhlIG92
ZXIgdGhlDQpsb29wYmFjayBuZXR3b3JrIGRyaXZlcj8gSSB0aGluayBhbGwgdGhyZWUgZHJpdmVy
IHN0YWNrcyBzdXBwb3J0IHplcm8tY29weQ0KcmVjZWl2aW5nLCBzb21ldGhpbmcgdGhhdCBpcyBu
b3QgcG9zc2libGUgd2l0aCBpU0NTSS9UQ1Agbm9yIHdpdGggQW9FLg0KDQpCYXJ0Lg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
