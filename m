Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id A5FA26B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 22:34:12 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id a29so134324256qtb.6
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 19:34:12 -0800 (PST)
Received: from us-smtp-delivery-194.mimecast.com (us-smtp-delivery-194.mimecast.com. [216.205.24.194])
        by mx.google.com with ESMTPS id i5si12208218qkh.146.2017.01.23.19.34.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 23 Jan 2017 19:34:11 -0800 (PST)
From: Trond Myklebust <trondmy@primarydata.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] I/O error handling and fsync()
Date: Tue, 24 Jan 2017 03:34:04 +0000
Message-ID: <1485228841.8987.1.camel@primarydata.com>
References: <20170110160224.GC6179@noname.redhat.com>
	 <87k2a2ig2c.fsf@notabene.neil.brown.name>
	 <20170113110959.GA4981@noname.redhat.com>
	 <20170113142154.iycjjhjujqt5u2ab@thunk.org>
	 <20170113160022.GC4981@noname.redhat.com>
	 <87mveufvbu.fsf@notabene.neil.brown.name>
	 <1484568855.2719.3.camel@poochiereds.net>
	 <87o9yyemud.fsf@notabene.neil.brown.name>
	 <1485127917.5321.1.camel@poochiereds.net>
	 <20170123002158.xe7r7us2buc37ybq@thunk.org>
	 <20170123100941.GA5745@noname.redhat.com>
	 <1485210957.2786.19.camel@poochiereds.net>
	 <1485212994.3722.1.camel@primarydata.com>
	 <878tq1ia6l.fsf@notabene.neil.brown.name>
In-Reply-To: <878tq1ia6l.fsf@notabene.neil.brown.name>
Content-Language: en-US
Content-ID: <E540B895DEFC81499C06CA60938BA26B@namprd11.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "kwolf@redhat.com" <kwolf@redhat.com>, "jlayton@poochiereds.net" <jlayton@poochiereds.net>, "neilb@suse.com" <neilb@suse.com>, "tytso@mit.edu" <tytso@mit.edu>
Cc: "hch@infradead.org" <hch@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "rwheeler@redhat.com" <rwheeler@redhat.com>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

T24gVHVlLCAyMDE3LTAxLTI0IGF0IDExOjE2ICsxMTAwLCBOZWlsQnJvd24gd3JvdGU6DQo+IE9u
IE1vbiwgSmFuIDIzIDIwMTcsIFRyb25kIE15a2xlYnVzdCB3cm90ZToNCj4gDQo+ID4gT24gTW9u
LCAyMDE3LTAxLTIzIGF0IDE3OjM1IC0wNTAwLCBKZWZmIExheXRvbiB3cm90ZToNCj4gPiA+IE9u
IE1vbiwgMjAxNy0wMS0yMyBhdCAxMTowOSArMDEwMCwgS2V2aW4gV29sZiB3cm90ZToNCj4gPiA+
ID4gDQo+ID4gPiA+IEhvd2V2ZXIsIGlmIHdlIGxvb2sgYXQgdGhlIGdyZWF0ZXIgcHJvYmxlbSBv
ZiBoYW5naW5nIHJlcXVlc3RzDQo+ID4gPiA+IHRoYXQNCj4gPiA+ID4gY2FtZQ0KPiA+ID4gPiB1
cCBpbiB0aGUgbW9yZSByZWNlbnQgZW1haWxzIG9mIHRoaXMgdGhyZWFkLCBpdCBpcyBvbmx5IG1v
dmVkDQo+ID4gPiA+IHJhdGhlcg0KPiA+ID4gPiB0aGFuIHNvbHZlZC4gQ2hhbmNlcyBhcmUgdGhh
dCBhbHJlYWR5IHdyaXRlKCkgd291bGQgaGFuZyBub3cNCj4gPiA+ID4gaW5zdGVhZCBvZg0KPiA+
ID4gPiBvbmx5IGZzeW5jKCksIGJ1dCB3ZSBzdGlsbCBoYXZlIGEgaGFyZCB0aW1lIGRlYWxpbmcg
d2l0aCB0aGlzLg0KPiA+ID4gPiANCj4gPiA+IA0KPiA+ID4gV2VsbCwgaXQgX2lzXyBiZXR0ZXIg
d2l0aCBPX0RJUkVDVCBhcyB5b3UgY2FuIHVzdWFsbHkgYXQgbGVhc3QNCj4gPiA+IGJyZWFrDQo+
ID4gPiBvdXQNCj4gPiA+IG9mIHRoZSBJL08gd2l0aCBTSUdLSUxMLg0KPiA+ID4gDQo+ID4gPiBX
aGVuIEkgbGFzdCBsb29rZWQgYXQgdGhpcywgdGhlIHByb2JsZW0gd2l0aCBidWZmZXJlZCBJL08g
d2FzDQo+ID4gPiB0aGF0DQo+ID4gPiB5b3UNCj4gPiA+IG9mdGVuIGVuZCB1cCB3YWl0aW5nIG9u
IHBhZ2UgYml0cyB0byBjbGVhciAodXN1YWxseSBQR193cml0ZWJhY2sNCj4gPiA+IG9yDQo+ID4g
PiBQR19kaXJ0eSksIGluIG5vbi1raWxsYWJsZSBzbGVlcHMgZm9yIHRoZSBtb3N0IHBhcnQuDQo+
ID4gPiANCj4gPiA+IE1heWJlIHRoZSBmaXggaGVyZSBpcyBhcyBzaW1wbGUgYXMgY2hhbmdpbmcg
dGhhdD8NCj4gPiANCj4gPiBBdCB0aGUgcmlzayBvZiBraWNraW5nIG9mZiBhbm90aGVyIE9fUE9O
SUVTIGRpc2N1c3Npb246IEFkZCBhbg0KPiA+IG9wZW4oT19USU1FT1VUKSBmbGFnIHRoYXQgd291
bGQgbGV0IHRoZSBrZXJuZWwga25vdyB0aGF0IHRoZQ0KPiA+IGFwcGxpY2F0aW9uIGlzIHByZXBh
cmVkIHRvIGhhbmRsZSB0aW1lb3V0cyBmcm9tIG9wZXJhdGlvbnMgc3VjaCBhcw0KPiA+IHJlYWQo
KSwgd3JpdGUoKSBhbmQgZnN5bmMoKSwgdGhlbiBhZGQgYW4gaW9jdGwoKSBvciBzeXNjYWxsIHRv
DQo+ID4gYWxsb3cNCj4gPiBzYWlkIGFwcGxpY2F0aW9uIHRvIHNldCB0aGUgdGltZW91dCB2YWx1
ZS4NCj4gDQo+IEkgd2FzIHRoaW5raW5nIG9uIHZlcnkgc2ltaWxhciBsaW5lcywgdGhvdWdoIEkn
ZCB1c2UgJ2ZjbnRsKCknIGlmDQo+IHBvc3NpYmxlIGJlY2F1c2UgaXQgd291bGQgYmUgYSBwZXIt
ImZpbGUgZGVzY3JpcHRpb24iIG9wdGlvbi4NCj4gVGhpcyB3b3VsZCBiZSBhIGZ1bmN0aW9uIG9m
IHRoZSBwYWdlIGNhY2hlLCBhbmQgYSBmaWxlc3lzdGVtIHdvdWxkbid0DQo+IG5lZWQgdG8ga25v
dyBhYm91dCBpdCBhdCBhbGwuwqDCoE9uY2UgZW5hYmxlLCAncmVhZCcsICd3cml0ZScsIG9yDQo+
ICdmc3luYycNCj4gd291bGQgcmV0dXJuIEVXT1VMREJMT0NLIHJhdGhlciB0aGFuIHdhaXRpbmcg
aW5kZWZpbml0ZWx5Lg0KPiBJdCBtaWdodCBiZSBuaWNlIGlmICdzZWxlY3QnIGNvdWxkIHRoZW4g
YmUgdXNlZCBvbiBwYWdlLWNhY2hlIGZpbGUNCj4gZGVzY3JpcHRvcnMsIGJ1dCBJIHRoaW5rIHRo
YXQgaXMgbXVjaCBoYXJkZXIuwqDCoFN1cHBvcnQgT19USU1FT1VUDQo+IHdvdWxkDQo+IGJlIGEg
cHJhY3RpY2FsIGZpcnN0IHN0ZXAgLSBpZiBzb21lb25lIGFncmVlZCB0byBhY3R1YWxseSB0cnkg
dG8gdXNlDQo+IGl0Lg0KDQpUaGUgcmVhc29uIHdoeSBJJ20gdGhpbmtpbmcgb3BlbigpIGlzIGJl
Y2F1c2UgaXQgaGFzIHRvIGJlIGEgY29udHJhY3QNCmJldHdlZW4gYSBzcGVjaWZpYyBhcHBsaWNh
dGlvbiBhbmQgdGhlIGtlcm5lbC4gSWYgdGhlIGFwcGxpY2F0aW9uDQpkb2Vzbid0IG9wZW4gdGhl
IGZpbGUgd2l0aCB0aGUgT19USU1FT1VUIGZsYWcsIHRoZW4gaXQgc2hvdWxkbid0IHNlZQ0KbmFz
dHkgbm9uLVBPU0lYIHRpbWVvdXQgZXJyb3JzLCBldmVuIGlmIHRoZXJlIGlzIGFub3RoZXIgcHJv
Y2VzcyB0aGF0DQppcyB1c2luZyB0aGF0IGZsYWcgb24gdGhlIHNhbWUgZmlsZS4NCg0KVGhlIG9u
bHkgcGxhY2Ugd2hlcmUgdGhhdCBpcyBkaWZmaWN1bHQgdG8gbWFuYWdlIGlzIHdoZW4gdGhlIGZp
bGUgaXMNCm1tYXAoKWVkIChubyBmaWxlIGRlc2NyaXB0b3IpLCBzbyB5b3UnZCBwcmVzdW1hYmx5
IGhhdmUgdG8gZGlzYWxsb3cNCm1peGluZyBtbWFwIGFuZCBPX1RJTUVPVVQuDQoNCi0tIA0KVHJv
bmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIFByaW1hcnlEYXRhDQp0
cm9uZC5teWtsZWJ1c3RAcHJpbWFyeWRhdGEuY29tDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
