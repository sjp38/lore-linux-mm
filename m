Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4669B6B000A
	for <linux-mm@kvack.org>; Tue, 29 May 2018 12:10:30 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id j2-v6so8098269qtn.10
        for <linux-mm@kvack.org>; Tue, 29 May 2018 09:10:30 -0700 (PDT)
Received: from g2t2353.austin.hpe.com (g2t2353.austin.hpe.com. [15.233.44.26])
        by mx.google.com with ESMTPS id s72-v6si4314816qka.20.2018.05.29.09.10.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 09:10:28 -0700 (PDT)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [PATCH v3 3/3] x86/mm: add TLB purge to free pmd/pte page
 interfaces
Date: Tue, 29 May 2018 16:10:24 +0000
Message-ID: <1527610139.14039.58.camel@hpe.com>
References: <20180516233207.1580-1-toshi.kani@hpe.com>
	 <20180516233207.1580-4-toshi.kani@hpe.com>
	 <20180529144438.GM18595@8bytes.org>
In-Reply-To: <20180529144438.GM18595@8bytes.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <5FE68D1B24EC864AB1AB93BAB88D0146@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "tglx@linutronix.de" <tglx@linutronix.de>, "joro@8bytes.org" <joro@8bytes.org>, "mingo@redhat.com" <mingo@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "Hocko, Michal" <MHocko@suse.com>

T24gVHVlLCAyMDE4LTA1LTI5IGF0IDE2OjQ0ICswMjAwLCBKb2VyZyBSb2VkZWwgd3JvdGU6DQo+
IE9uIFdlZCwgTWF5IDE2LCAyMDE4IGF0IDA1OjMyOjA3UE0gLTA2MDAsIFRvc2hpIEthbmkgd3Jv
dGU6DQo+ID4gIAlwbWQgPSAocG1kX3QgKilwdWRfcGFnZV92YWRkcigqcHVkKTsNCj4gPiArCXBt
ZF9zdiA9IChwbWRfdCAqKV9fZ2V0X2ZyZWVfcGFnZShHRlBfS0VSTkVMKTsNCj4gPiArCWlmICgh
cG1kX3N2KQ0KPiA+ICsJCXJldHVybiAwOw0KPiANCj4gU28geW91ciBjb2RlIHN0aWxsIG5lZWRz
IHRvIGFsbG9jYXRlIGEgZnVsbCBwYWdlIHdoZXJlIGEgc2ltcGxlDQo+IGxpc3RfaGVhZCBvbiB0
aGUgc3RhY2sgd291bGQgZG8gdGhlIHNhbWUgam9iLg0KDQpDYW4geW91IGV4cGxhaW4gd2h5IHlv
dSB0aGluayBhbGxvY2F0aW5nIGEgcGFnZSBoZXJlIGlzIGEgbWFqb3IgcHJvYmxlbT8NCiANCkFz
IEkgZXhwbGFpbmVkIGJlZm9yZSwgcHVkX2ZyZWVfcG1kX3BhZ2UoKSBjb3ZlcnMgYW4gZXh0cmVt
ZWx5IHJhcmUgY2FzZQ0KIHdoaWNoIEkgY291bGQgbm90IGV2ZW4gaGl0IHdpdGggYSBodWdlIG51
bWJlciBvZiBpb3JlbWFwKCkgY2FsbHMgdW50aWwNCkkgaW5zdHJ1bWVudGVkIGFsbG9jX3ZtYXBf
YXJlYSgpIHRvIGZvcmNlIHRoaXMgY2FzZSB0byBoYXBwZW4uICBJIGRvIG5vdA0KdGhpbmsgcGFn
ZXMgc2hvdWxkIGJlIGxpc3RlZCBmb3Igc3VjaCBhIHJhcmUgY2FzZS4NCg0KPiBJbmdvLCBUaG9t
YXMsIGNhbiB5b3UgcGxlYXNlIGp1c3QgcmV2ZXJ0IHRoZSBvcmlnaW5hbCBicm9rZW4gcGF0Y2gg
Zm9yDQo+IG5vdyB1bnRpbCB0aGVyZSBpcyBwcm9wZXIgZml4Pw0KDQpJZiB3ZSBqdXN0IHJldmVy
dCwgcGxlYXNlIGFwcGx5IHBhdGNoIDEvMyBmaXJzdC4gIFRoaXMgcGF0Y2ggYWRkcmVzcyB0aGUN
CkJVR19PTiBpc3N1ZSBvbiBQQUUuICBUaGlzIGlzIGEgcmVhbCBpc3N1ZSB0aGF0IG5lZWRzIGEg
Zml4IEFTQVAuDQoNClRoZSBwYWdlLWRpcmVjdG9yeSBjYWNoZSBpc3N1ZSBvbiB4NjQsIHdoaWNo
IGlzIGFkZHJlc3NlZCBieSBwYXRjaCAzLzMsDQppcyBhIHRoZW9yZXRpY2FsIGlzc3VlIHRoYXQg
SSBjb3VsZCBub3QgaGl0IGJ5IHB1dHRpbmcgaW9yZW1hcCgpIGNhbGxzDQppbnRvIGEgbG9vcCBm
b3IgYSB3aG9sZSBkYXkuICBOb2JvZHkgaGl0IHRoaXMgaXNzdWUsIGVpdGhlci4NCg0KVGhlIHNp
bXBsZSByZXZlcnQgcGF0Y2ggSm9lcmcgcG9zdGVkIGEgd2hpbGUgYWdvIGNhdXNlcw0KcG1kX2Zy
ZWVfcHRlX3BhZ2UoKSB0byBmYWlsIG9uIHg2NC4gIFRoaXMgY2F1c2VzIG11bHRpcGxlIHBtZCBt
YXBwaW5ncw0KdG8gZmFsbCBpbnRvIHB0ZSBtYXBwaW5ncyBvbiBteSB0ZXN0IHN5c3RlbXMuICBU
aGlzIGNhbiBiZSBzZWVuIGFzIGENCmRlZ3JhZGF0aW9uLCBhbmQgSSBhbSBhZnJhaWQgdGhhdCBp
dCBpcyBtb3JlIGhhcm1mdWwgdGhhbiBnb29kLg0KDQpUaGFua3MsDQotVG9zaGkNCg==
