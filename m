Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4E02D6B0007
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 21:52:26 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id d2-v6so3293802pgq.22
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 18:52:26 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id m3-v6si9632369pgu.237.2018.06.11.18.52.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jun 2018 18:52:24 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 00/11] mm: Teach memory_failure() about ZONE_DEVICE
 pages
Date: Tue, 12 Jun 2018 01:50:26 +0000
Message-ID: <20180612015025.GA25302@hori1.linux.bs1.fc.nec.co.jp>
References: <20180605141104.GF19202@dhcp22.suse.cz>
 <CAPcyv4iGd56kc2NG5GDYMqW740RNr7NZr9DRft==fPxPyieq7Q@mail.gmail.com>
 <20180606073910.GB32433@dhcp22.suse.cz>
 <CAPcyv4hA2Na7wyuyLZSWG5s_4+pEv6aMApk23d2iO1vhFx92XQ@mail.gmail.com>
 <20180607143724.GS32433@dhcp22.suse.cz>
 <CAPcyv4jnyuC-yjuSgu4qKtzB0h9yYMZDsg5Rqqa=HTCY9KM_gw@mail.gmail.com>
 <20180611075004.GH13364@dhcp22.suse.cz>
 <CAPcyv4gSTMEi5XdzLQZqxMMKCcwF=me02wCiRtAAXSiy2CPGJA@mail.gmail.com>
 <20180611145636.GP13364@dhcp22.suse.cz>
 <CAPcyv4hnPRk0hTGctHB4tBnyL_27x3DwPUVwhZ+L7c-=1Xdf6Q@mail.gmail.com>
In-Reply-To: <CAPcyv4hnPRk0hTGctHB4tBnyL_27x3DwPUVwhZ+L7c-=1Xdf6Q@mail.gmail.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="utf-8"
Content-ID: <EEF08FD135FF2A428BE30E95E4F764B5@gisp.nec.co.jp>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, "linux-edac@vger.kernel.org" <linux-edac@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Borislav Petkov <bp@alien8.de>, =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Christoph Hellwig <hch@lst.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Ingo Molnar <mingo@redhat.com>, Souptick Joarder <jrdr.linux@gmail.com>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>

T24gTW9uLCBKdW4gMTEsIDIwMTggYXQgMDg6MTk6NTRBTSAtMDcwMCwgRGFuIFdpbGxpYW1zIHdy
b3RlOg0KPiBPbiBNb24sIEp1biAxMSwgMjAxOCBhdCA3OjU2IEFNLCBNaWNoYWwgSG9ja28gPG1o
b2Nrb0BrZXJuZWwub3JnPiB3cm90ZToNCj4gPiBPbiBNb24gMTEtMDYtMTggMDc6NDQ6MzksIERh
biBXaWxsaWFtcyB3cm90ZToNCj4gPiBbLi4uXQ0KPiA+PiBJJ20gc3RpbGwgdHJ5aW5nIHRvIHVu
ZGVyc3RhbmQgdGhlIG5leHQgbGV2ZWwgb2YgZGV0YWlsIG9uIHdoZXJlIHlvdQ0KPiA+PiB0aGlu
ayB0aGUgZGVzaWduIHNob3VsZCBnbyBuZXh0PyBJcyBpdCBqdXN0IHRoZSBIV1BvaXNvbiBwYWdl
IGZsYWc/DQo+ID4+IEFyZSB5b3UgY29uY2VybmVkIGFib3V0IHN1cHBvcnRpbmcgZ3JlYXRlciB0
aGFuIFBBR0VfU0laRSBwb2lzb24/DQo+ID4NCj4gPiBJIHNpbXBseSBkbyBub3Qgd2FudCB0byBj
aGVjayBmb3IgSFdQb2lzb24gYXQgemlsbGlvbiBvZiBwbGFjZXMgYW5kIGhhdmUNCj4gPiBlYWNo
IHR5cGUgb2YgcGFnZSB0byBoYXZlIHNvbWUgc3BlY2lhbCBoYW5kbGluZyB3aGljaCBjYW4gZ2V0
IHdyb25nIHZlcnkNCj4gPiBlYXNpbHkuIEkgYW0gbm90IGNsZWFyIG9uIGRldGFpbHMgaGVyZSwg
dGhpcyBpcyBzb21ldGhpbmcgZm9yIHVzZXJzIG9mDQo+ID4gaHdwb2lzb24gdG8gZGVmaW5lIHdo
YXQgaXMgdGhlIHJlYXNvbmFibGUgc2NlbmFyaW9zIHdoZW4gdGhlIGZlYXR1cmUgaXMNCj4gPiB1
c2VmdWwgYW5kIHR1cm4gdGhhdCBpbnRvIGEgZmVhdHVyZSBsaXN0IHRoYXQgY2FuIGJlIGFjdHVh
bGx5IHR1cm5lZA0KPiA+IGludG8gYSBkZXNpZ24gZG9jdW1lbnQuIFNlZSB0aGUgZGlmZmVyZW50
IGZyb20gbGV0J3MgcHV0IHNvbWUgbW9yZSBvbg0KPiA+IHRvcCBhcHByb2FjaC4uLg0KPiA+DQo+
IA0KPiBTbyB5b3Ugd2FudCBtZSB0byBwYXkgdGhlIHRvbGwgb2Ygd3JpdGluZyBhIGRlc2lnbiBk
b2N1bWVudCBqdXN0aWZ5aW5nDQo+IGFsbCB0aGUgZXhpc3RpbmcgdXNlIGNhc2VzIG9mIEhXUG9p
c29uIGJlZm9yZSB3ZSBmaXggdGhlIERBWCBidWdzLCBhbmQNCj4gdGhlIGRlc2lnbiBkb2N1bWVu
dCBtYXkgb3IgbWF5IG5vdCByZXN1bHQgaW4gYW55IHN1YnN0YW50aXZlIGNoYW5nZSB0bw0KPiB0
aGVzZSBwYXRjaGVzPw0KPiANCj4gTmFveWEgb3IgQW5kaSwgY2FuIHlvdSBjaGltZSBpbiBoZXJl
Pw0KDQptZW1vcnlfZmFpbHVyZSgpIGRvZXMgMyB0aGluZ3M6DQoNCiAtIHVubWFwcGluZyB0aGUg
ZXJyb3IgcGFnZSBmcm9tIHByb2Nlc3NlcyB1c2luZyBpdCwNCiAtIGlzb2xhdGluZyB0aGUgZXJy
b3IgcGFnZSB3aXRoIFBhZ2VIV1BvaXNvbiwNCiAtIGxvZ2dpbmcvcmVwb3J0aW5nLg0KDQpUaGUg
dW5tYXBwaW5nIHBhcnQgYW5kIHRoZSBpc29sYXRpbmcgcGFydCBhcmUgcXVpdGUgcGFnZSB0eXBl
IGRlcGVuZGVudCwNCnNvIHRoaXMgc2VlbXMgdG8gbWUgaGFyZCB0byBkbyB0aGVtIGluIGdlbmVy
aWMgbWFubmVyIChzbyBzdXBwb3J0aW5nIG5ldw0KcGFnZSB0eXBlIGFsd2F5cyBuZWVkcyBjYXNl
IHNwZWNpZmljIG5ldyBjb2RlLikNCkJ1dCBJIGFncmVlIHRoYXQgd2UgY2FuIGltcHJvdmUgY29k
ZSBhbmQgZG9jdW1lbnQgdG8gaGVscCBkZXZlbG9wZXJzIGFkZA0Kc3VwcG9ydCBmb3IgbmV3IHBh
Z2UgdHlwZS4NCg0KQWJvdXQgZG9jdW1lbnRpbmcsIHRoZSBjb250ZW50IG9mIERvY3VtZW50YXRp
b24vdm0vaHdwb2lzb24ucnN0IGlzIG5vdA0KdXBkYXRlZCBzaW5jZSAyMDA5LCBzbyBzb21lIHVw
ZGF0ZSB3aXRoIGRlc2lnbiB0aGluZyBtaWdodCBiZSByZXF1aXJlZC4NCk15IGN1cnJlbnQgdGhv
dWdodCBhYm91dCB1cGRhdGUgaXRlbXMgYXJlIGxpa2UgdGhpczoNCg0KICAtIGRldGFpbGluZyBn
ZW5lcmFsIHdvcmtmbG93LA0KICAtIGFkZGluZyBzb21lIGFib3V0IHNvZnQgb2ZmbGluZSwNCiAg
LSBndWlkZWxpbmUgZm9yIGRldmVsb3BlcnMgdG8gc3VwcG9ydCBuZXcgdHlwZSBvZiBtZW1vcnks
DQogICgtIGFuZCBhbnl0aGluZyBoZWxwZnVsL3JlcXVlc3RlZC4pDQoNCk1ha2luZyBjb2RlIG1v
cmUgcmVhZGFibGUvc2VsZi1kZXNjcmlwdGl2ZSBpcyBoZWxwZnVsLCB0aG91Z2ggSSdtDQpub3Qg
Y2xlYXIgbm93IGFib3V0IGhvdy4NCg0KQW55d2F5IEknbGwgZmluZCB0aW1lIHRvIHdvcmsgb24g
dGhpcywgd2hpbGUgbm93IEknbSB0ZXN0aW5nIHRoZSBkYXgNCnN1cHBvcnQgcGF0Y2hlcyBhbmQg
Zml4aW5nIGEgYnVnIEkgZm91bmQgcmVjZW50bHkuDQoNClRoYW5rcywNCk5hb3lhIEhvcmlndWNo
aQ==
