Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7170A6B007E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 13:14:39 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e190so379998586pfe.3
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 10:14:39 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id n3si7667470pfb.123.2016.04.25.10.14.38
        for <linux-mm@kvack.org>;
        Mon, 25 Apr 2016 10:14:38 -0700 (PDT)
From: "Verma, Vishal L" <vishal.l.verma@intel.com>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
Date: Mon, 25 Apr 2016 17:14:36 +0000
Message-ID: <1461604476.3106.12.camel@intel.com>
References: <1459303190-20072-1-git-send-email-vishal.l.verma@intel.com>
	 <1459303190-20072-6-git-send-email-vishal.l.verma@intel.com>
	 <x49twj26edj.fsf@segfault.boston.devel.redhat.com>
	 <20160420205923.GA24797@infradead.org> <1461434916.3695.7.camel@intel.com>
	 <20160425083114.GA27556@infradead.org>
In-Reply-To: <20160425083114.GA27556@infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <80F5C603E926CF47BF71F79A2B125709@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "hch@infradead.org" <hch@infradead.org>
Cc: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "jmoyer@redhat.com" <jmoyer@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "axboe@fb.com" <axboe@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "david@fromorbit.com" <david@fromorbit.com>, "jack@suse.cz" <jack@suse.cz>

T24gTW9uLCAyMDE2LTA0LTI1IGF0IDAxOjMxIC0wNzAwLCBoY2hAaW5mcmFkZWFkLm9yZyB3cm90
ZToNCj4gT24gU2F0LCBBcHIgMjMsIDIwMTYgYXQgMDY6MDg6MzdQTSArMDAwMCwgVmVybWEsIFZp
c2hhbCBMIHdyb3RlOg0KPiA+IA0KPiA+IGRpcmVjdF9JTyBtaWdodCBmYWlsIHdpdGggLUVJTlZB
TCBkdWUgdG8gbWlzYWxpZ25tZW50LCBvciAtRU5PTUVNDQo+ID4gZHVlDQo+ID4gdG8gc29tZSBh
bGxvY2F0aW9uIGZhaWxpbmcsIGFuZCBJIHRob3VnaHQgd2Ugc2hvdWxkIHJldHVybiB0aGUNCj4g
PiBvcmlnaW5hbA0KPiA+IC1FSU8gaW4gc3VjaCBjYXNlcyBzbyB0aGF0IHRoZSBhcHBsaWNhdGlv
biBkb2Vzbid0IGxvc2UgdGhlDQo+ID4gaW5mb3JtYXRpb24NCj4gPiB0aGF0IHRoZSBiYWQgYmxv
Y2sgaXMgYWN0dWFsbHkgY2F1c2luZyB0aGUgZXJyb3IuDQo+IEVJTlZBTCBpcyBhIGNvbmNlcm4g
aGVyZS7CoMKgTm90IGR1ZSB0byB0aGUgcmlnaHQgZXJyb3IgcmVwb3J0ZWQsIGJ1dA0KPiBiZWNh
dXNlIGl0IG1lYW5zIHlvdXIgY3VycmVudCBzY2hlbWUgaXMgZnVuZGFtZW50YWxseSBicm9rZW4g
LSB3ZQ0KPiBuZWVkIHRvIHN1cHBvcnQgSS9PIGF0IGFueSBhbGlnbm1lbnQgZm9yIERBWCBJL08s
IGFuZCBub3QgZmFpbCBkdWUgdG8NCj4gYWxpZ25ibWVudCBjb25jZXJuZXMgZm9yIGEgaGlnaGx5
IHNwZWNpZmljIGRlZ3JhZGVkIGNhc2UuDQo+IA0KPiBJIHRoaW5rIHRoaXMgd2hvbGUgc2VyaWVz
IG5lZWQgdG8gZ28gYmFjayB0byB0aGUgZHJhd2luZyBib2FyZCBhcyBJDQo+IGRvbid0IHRoaW5r
IGl0IGNhbiBhY3R1YWxseSByZWx5IG9uIHVzaW5nIGRpcmVjdCBJL08gYXMgdGhlIEVJTw0KPiBm
YWxsYmFjay4NCj4gDQpBZ3JlZWQgdGhhdCBEQVggSS9PIGNhbiBoYXBwZW4gd2l0aCBhbnkgc2l6
ZS9hbGlnbm1lbnQsIGJ1dCBob3cgZWxzZSBkbw0Kd2Ugc2VuZCBhbiBJTyB0aHJvdWdoIHRoZSBk
cml2ZXIgd2l0aG91dCBhbGlnbm1lbnQgcmVzdHJpY3Rpb25zPyBBbHNvLA0KdGhlIGdyYW51bGFy
aXR5IGF0IHdoaWNoIHdlIHN0b3JlIGJhZGJsb2NrcyBpcyA1MTJCIHNlY3RvcnMsIHNvIGl0DQpz
ZWVtcyBuYXR1cmFsIHRoYXQgdG8gY2xlYXIgc3VjaCBhIHNlY3RvciwgeW91J2QgZXhwZWN0IHRv
IHNlbmQgYSB3cml0ZQ0KdG8gdGhlIHdob2xlIHNlY3Rvci4NCg0KVGhlIGV4cGVjdGVkIHVzYWdl
IGZsb3cgaXM6DQoNCi0gQXBwbGljYXRpb24gaGl0cyBFSU8gZG9pbmcgZGF4X0lPIG9yIGxvYWQv
c3RvcmUgaW8NCg0KLSBJdCBjaGVja3MgYmFkYmxvY2tzIGFuZCBkaXNjb3ZlcnMgaXQncyBmaWxl
cyBoYXZlIGxvc3QgZGF0YQ0KDQotIEl0IHdyaXRlKClzIHRob3NlIHNlY3RvcnMgKHBvc3NpYmx5
IGNvbnZlcnRlZCB0byBmaWxlIG9mZnNldHMgdXNpbmcNCmZpZW1hcCkNCsKgIMKgICogVGhpcyB0
cmlnZ2VycyB0aGUgZmFsbGJhY2sgcGF0aCwgYnV0IGlmIHRoZSBhcHBsaWNhdGlvbiBpcyBkb2lu
Zw0KdGhpcyBsZXZlbCBvZiByZWNvdmVyeSwgaXQgd2lsbCBrbm93IHRoZSBzZWN0b3IgaXMgYmFk
LCBhbmQgd3JpdGUgdGhlDQplbnRpcmUgc2VjdG9yDQoNCi0gT3IgaXQgcmVwbGFjZXMgdGhlIGVu
dGlyZSBmaWxlIGZyb20gYmFja3VwIGFsc28gdXNpbmcgd3JpdGUoKSAobm90DQptbWFwK3N0b3Jl
cykNCsKgIMKgICogVGhpcyBqdXN0IGZyZWVzIHRoZSBmcyBibG9jaywgYW5kIHRoZSBuZXh0IHRp
bWUgdGhlIGJsb2NrIGlzDQpyZWFsbG9jYXRlZCBieSB0aGUgZnMsIGl0IHdpbGwgbGlrZWx5IGJl
IHplcm9lZCBmaXJzdCwgYW5kIHRoYXQgd2lsbCBiZQ0KZG9uZSB0aHJvdWdoIHRoZSBkcml2ZXIg
YW5kIHdpbGwgY2xlYXIgZXJyb3JzDQoNCg0KSSB0aGluayBpZiB3ZSB3YW50IHRvIGtlZXAgYWxs
b3dpbmcgYXJiaXRyYXJ5IGFsaWdubWVudHMgZm9yIHRoZQ0KZGF4X2RvX2lvIHBhdGgsIHdlJ2Qg
bmVlZDoNCjEuIFRvIHJlcHJlc2VudCBiYWRibG9ja3MgYXQgYSBmaW5lciBncmFudWxhcml0eSAo
bGlrZWx5IGNhY2hlIGxpbmVzKQ0KMi4gVG8gYWxsb3cgdGhlIGRyaXZlciB0byBkbyBJTyB0byBh
ICpibG9jayBkZXZpY2UqIGF0IHN1Yi1zZWN0b3INCmdyYW51bGFyaXR5DQoNCkNhbiB3ZSBkbyB0
aGF0Pw==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
