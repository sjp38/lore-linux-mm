Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 55A6E6B025E
	for <linux-mm@kvack.org>; Thu,  5 May 2016 17:42:15 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id gw7so132300901pac.0
        for <linux-mm@kvack.org>; Thu, 05 May 2016 14:42:15 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id ey9si13603833pab.123.2016.05.05.14.42.14
        for <linux-mm@kvack.org>;
        Thu, 05 May 2016 14:42:14 -0700 (PDT)
From: "Verma, Vishal L" <vishal.l.verma@intel.com>
Subject: Re: [PATCH v4 5/7] fs: prioritize and separate direct_io from dax_io
Date: Thu, 5 May 2016 21:42:12 +0000
Message-ID: <1462484521.29294.4.camel@intel.com>
References: <1461878218-3844-1-git-send-email-vishal.l.verma@intel.com>
	 <1461878218-3844-6-git-send-email-vishal.l.verma@intel.com>
	 <5727753F.6090104@plexistor.com> <20160505142433.GA4557@infradead.org>
	 <CAPcyv4gdmo5m=Arf5sp5izJfNaaAkaaMbOzud8KRcBEC8RRu1Q@mail.gmail.com>
In-Reply-To: <CAPcyv4gdmo5m=Arf5sp5izJfNaaAkaaMbOzud8KRcBEC8RRu1Q@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <353BB2C55CB22643BBB65F3CF6BFC153@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Williams, Dan J" <dan.j.williams@intel.com>, "hch@infradead.org" <hch@infradead.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "axboe@fb.com" <axboe@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "david@fromorbit.com" <david@fromorbit.com>, "jack@suse.cz" <jack@suse.cz>, "matthew@wil.cx" <matthew@wil.cx>

T24gVGh1LCAyMDE2LTA1LTA1IGF0IDA4OjE1IC0wNzAwLCBEYW4gV2lsbGlhbXMgd3JvdGU6DQo+
IE9uIFRodSwgTWF5IDUsIDIwMTYgYXQgNzoyNCBBTSwgQ2hyaXN0b3BoIEhlbGx3aWcgPGhjaEBp
bmZyYWRlYWQub3JnPg0KPiB3cm90ZToNCj4gPiANCj4gPiBPbiBNb24sIE1heSAwMiwgMjAxNiBh
dCAwNjo0MTo1MVBNICswMzAwLCBCb2F6IEhhcnJvc2ggd3JvdGU6DQo+ID4gPiANCj4gPiA+ID4g
DQo+ID4gPiA+IEFsbCBJTyBpbiBhIGRheCBmaWxlc3lzdGVtIHVzZWQgdG8gZ28gdGhyb3VnaCBk
YXhfZG9faW8sIHdoaWNoDQo+ID4gPiA+IGNhbm5vdA0KPiA+ID4gPiBoYW5kbGUgbWVkaWEgZXJy
b3JzLCBhbmQgdGh1cyBjYW5ub3QgcHJvdmlkZSBhIHJlY292ZXJ5IHBhdGgNCj4gPiA+ID4gdGhh
dCBjYW4NCj4gPiA+ID4gc2VuZCBhIHdyaXRlIHRocm91Z2ggdGhlIGRyaXZlciB0byBjbGVhciBl
cnJvcnMuDQo+ID4gPiA+IA0KPiA+ID4gPiBBZGQgYSBuZXcgaW9jYiBmbGFnIGZvciBEQVgsIGFu
ZCBzZXQgaXQgb25seSBmb3IgREFYIG1vdW50cy4gSW4NCj4gPiA+ID4gdGhlIElPDQo+ID4gPiA+
IHBhdGggZm9yIERBWCBmaWxlc3lzdGVtcywgdXNlIHRoZSBzYW1lIGRpcmVjdF9JTyBwYXRoIGZv
ciBib3RoDQo+ID4gPiA+IERBWCBhbmQNCj4gPiA+ID4gZGlyZWN0X2lvIGlvY2JzLCBidXQgdXNl
IHRoZSBmbGFncyB0byBpZGVudGlmeSB3aGVuIHdlIGFyZSBpbg0KPiA+ID4gPiBPX0RJUkVDVA0K
PiA+ID4gPiBtb2RlIHZzIG5vbiBPX0RJUkVDVCB3aXRoIERBWCwgYW5kIGZvciBPX0RJUkVDVCwg
dXNlIHRoZQ0KPiA+ID4gPiBjb252ZW50aW9uYWwNCj4gPiA+ID4gZGlyZWN0X0lPIHBhdGggaW5z
dGVhZCBvZiBEQVguDQo+ID4gPiA+IA0KPiA+ID4gUmVhbGx5PyBXaGF0IGFyZSB5b3VyIHRoaW5r
aW5nIGhlcmU/DQo+ID4gPiANCj4gPiA+IFdoYXQgYWJvdXQgYWxsIHRoZSBjdXJyZW50IHVzZXJz
IG9mIE9fRElSRUNULCB5b3UgaGF2ZSBqdXN0IG1hZGUNCj4gPiA+IHRoZW0NCj4gPiA+IDQgdGlt
ZXMgc2xvd2VyIGFuZCAibGVzcyBjb25jdXJyZW50KiIgdGhlbiAiYnVmZnJlZCBpbyIgdXNlcnMu
DQo+ID4gPiBTaW5jZQ0KPiA+ID4gZGlyZWN0X0lPIHBhdGggd2lsbCBxdWV1ZSBhbiBJTyByZXF1
ZXN0IGFuZCBhbGwuDQo+ID4gPiAoQW5kIGlmIGl0IGlzIG5vdCBzbyBzbG93IHRoZW4gd2h5IGRv
IHdlIG5lZWQgZGF4X2RvX2lvIGF0IGFsbD8NCj4gPiA+IFtSaGV0b3JpY2FsXSkNCj4gPiA+IA0K
PiA+ID4gSSBoYXRlIGl0IHRoYXQgeW91IG92ZXJsb2FkIHRoZSBzZW1hbnRpY3Mgb2YgYSBrbm93
biBhbmQgZXhwZWN0ZWQNCj4gPiA+IE9fRElSRUNUIGZsYWcsIGZvciBzcGVjaWFsIHBtZW0gcXVp
cmtzLiBUaGlzIGlzIGFuIGluY29tcGF0aWJsZQ0KPiA+ID4gYW5kIHVucmVsYXRlZCBvdmVybG9h
ZCBvZiB0aGUgc2VtYW50aWNzIG9mIE9fRElSRUNULg0KPiA+IEFncmVlZCAtIG1ha2lnIE9fRElS
RUNUIGxlc3MgZGlyZWN0IHRoYW4gbm90IGhhdmluZyBpdCBpcyBwbGFpbg0KPiA+IHN0dXBpZCwN
Cj4gPiBhbmQgSSBzb21laG93IG1pc3NlZCB0aGlzIGluaXRpYWxseS4NCj4gT2YgY291cnNlIEkg
ZGlzYWdyZWUgYmVjYXVzZSBsaWtlIERhdmUgYXJndWVzIGluIHRoZSBtc3luYyBjYXNlIHdlDQo+
IHNob3VsZCBkbyB0aGUgY29ycmVjdCB0aGluZyBmaXJzdCBhbmQgbWFrZSBpdCBmYXN0IGxhdGVy
LCBidXQgYWxzbw0KPiBsaWtlIERhdmUgdGhpcyBhcmd1aW5nIGluIGNpcmNsZXMgaXMgZ2V0dGlu
ZyB0aXJlc29tZS4NCj4gDQo+ID4gDQo+ID4gVGhpcyB3aG9sZSBEQVggc3RvcnkgdHVybnMgaW50
byBhIG1ham9yIG5pZ2h0bWFyZSwgYW5kIEkgZmVhciBhbGwNCj4gPiBvdXINCj4gPiBob2RnZSBw
b2RnZSB0d2Vha3MgdG8gdGhlIHNlbWFudGljcyBhcmVuJ3QgaGVscGluZyBpdC4NCj4gPiANCj4g
PiBJdCBzZWVtcyBsaWtlIHdlIHNpbXBseSBuZWVkIGFuIGV4cGxpY2l0IE9fREFYIGZvciB0aGUg
cmVhZC93cml0ZQ0KPiA+IGJ5cGFzcyBpZiBjYW4ndCBzb3J0IG91dCB0aGUgc2VtYW50aWNzIChl
cnJvciwgd3JpdGVyDQo+ID4gc3luY2hyb25pemF0aW9uKQ0KPiA+IGp1c3QgYXMgd2UgbmVlZCBh
IHNwZWNpYWwgZmxhZyBmb3IgTU1BUC4NCj4gSSBkb24ndCBzZWUgaG93IE9fREFYIG1ha2VzIHRo
aXMgc2l0dWF0aW9uIGJldHRlciBpZiB0aGUgZ29hbCBpcyB0bw0KPiBhY2NlbGVyYXRlIHVubW9k
aWZpZWQgYXBwbGljYXRpb25zLi4uDQo+IA0KPiBWaXNoYWwsIGF0IGxlYXN0IHRoZSAiZGVsZXRl
IGEgZmlsZSB3aXRoIGEgYmFkYmxvY2siIG1vZGVsIHdpbGwgc3RpbGwNCj4gd29yayBmb3IgaW1w
bGljaXRseSBjbGVhcmluZyBlcnJvcnMgd2l0aCB5b3VyIGNoYW5nZXMgdG8gc3RvcCBkb2luZw0K
PiBibG9jayBjbGVhcmluZyBpbiBmcy9kYXguYy7CoMKgVGhpcyBjb21iaW5lZCB3aXRoIGEgbmV3
IC1FQkFEQkxPQ0sgKGFzDQo+IERhdmUgc3VnZ2VzdHMpIGFuZCBleHBsaWNpdCBsb2dnaW5nIG9m
IEkvT3MgdGhhdCBmYWlsIGZvciB0aGlzIHJlYXNvbg0KPiBhdCBsZWFzdCBnaXZlcyBhIGNoYW5j
ZSB0byBjb21tdW5pY2F0ZSBlcnJvcnMgaW4gZmlsZXMgdG8gc3VpdGFibHkNCj4gYXdhcmUgYXBw
bGljYXRpb25zIC8gZW52aXJvbm1lbnRzLg0KDQpBZ3JlZWQgLSBJJ2xsIHNlbmQgb3V0IGEgc2Vy
aWVzIHRoYXQgaGFzIGp1c3QgdGhlIHplcm9pbmcgY2hhbmdlcywgYW5kDQpkcm9wIHRoZSBkYXhf
aW8gZmFsbGJhY2svT19ESVJFQ1QgdHdlYWsgZm9yIG5vdyB3aGlsZSB3ZSBmaWd1cmUgb3V0IHRo
ZQ0KcmlnaHQgdGhpbmcgdG8gZG8uIFRoYXQgc2hvdWxkIGdldCB1cyB0byBhIHBsYWNlIHdoZXJl
IHdlIHN0aWxsIGhhdmUgZGF4DQppbiB0aGUgcHJlc2VuY2Ugb2YgZXJyb3JzLCBhbmQgaGF2ZSBf
YV8gcGF0aCBmb3IgcmVjb3ZlcnkuDQoNCj4gX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX18NCj4gTGludXgtbnZkaW1tIG1haWxpbmcgbGlzdA0KPiBMaW51eC1u
dmRpbW1AbGlzdHMuMDEub3JnDQo+IGh0dHBzOi8vbGlzdHMuMDEub3JnL21haWxtYW4vbGlzdGlu
Zm8vbGludXgtbnZkaW1t

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
