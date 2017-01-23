Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 854066B0038
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 18:10:02 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id f4so127841158qte.1
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 15:10:02 -0800 (PST)
Received: from us-smtp-delivery-194.mimecast.com (us-smtp-delivery-194.mimecast.com. [216.205.24.194])
        by mx.google.com with ESMTPS id e124si9385879qkf.17.2017.01.23.15.10.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 23 Jan 2017 15:10:01 -0800 (PST)
From: Trond Myklebust <trondmy@primarydata.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] I/O error handling and fsync()
Date: Mon, 23 Jan 2017 23:09:57 +0000
Message-ID: <1485212994.3722.1.camel@primarydata.com>
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
In-Reply-To: <1485210957.2786.19.camel@poochiereds.net>
Content-Language: en-US
Content-ID: <14FFED673CB5B7419C9979CD196924A4@namprd11.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "kwolf@redhat.com" <kwolf@redhat.com>, "jlayton@poochiereds.net" <jlayton@poochiereds.net>, "tytso@mit.edu" <tytso@mit.edu>
Cc: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "hch@infradead.org" <hch@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "neilb@suse.com" <neilb@suse.com>, "rwheeler@redhat.com" <rwheeler@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

T24gTW9uLCAyMDE3LTAxLTIzIGF0IDE3OjM1IC0wNTAwLCBKZWZmIExheXRvbiB3cm90ZToNCj4g
T24gTW9uLCAyMDE3LTAxLTIzIGF0IDExOjA5ICswMTAwLCBLZXZpbiBXb2xmIHdyb3RlOg0KPiA+
IA0KPiA+IEhvd2V2ZXIsIGlmIHdlIGxvb2sgYXQgdGhlIGdyZWF0ZXIgcHJvYmxlbSBvZiBoYW5n
aW5nIHJlcXVlc3RzIHRoYXQNCj4gPiBjYW1lDQo+ID4gdXAgaW4gdGhlIG1vcmUgcmVjZW50IGVt
YWlscyBvZiB0aGlzIHRocmVhZCwgaXQgaXMgb25seSBtb3ZlZA0KPiA+IHJhdGhlcg0KPiA+IHRo
YW4gc29sdmVkLiBDaGFuY2VzIGFyZSB0aGF0IGFscmVhZHkgd3JpdGUoKSB3b3VsZCBoYW5nIG5v
dw0KPiA+IGluc3RlYWQgb2YNCj4gPiBvbmx5IGZzeW5jKCksIGJ1dCB3ZSBzdGlsbCBoYXZlIGEg
aGFyZCB0aW1lIGRlYWxpbmcgd2l0aCB0aGlzLg0KPiA+IA0KPiANCj4gV2VsbCwgaXQgX2lzXyBi
ZXR0ZXIgd2l0aCBPX0RJUkVDVCBhcyB5b3UgY2FuIHVzdWFsbHkgYXQgbGVhc3QgYnJlYWsNCj4g
b3V0DQo+IG9mIHRoZSBJL08gd2l0aCBTSUdLSUxMLg0KPiANCj4gV2hlbiBJIGxhc3QgbG9va2Vk
IGF0IHRoaXMsIHRoZSBwcm9ibGVtIHdpdGggYnVmZmVyZWQgSS9PIHdhcyB0aGF0DQo+IHlvdQ0K
PiBvZnRlbiBlbmQgdXAgd2FpdGluZyBvbiBwYWdlIGJpdHMgdG8gY2xlYXIgKHVzdWFsbHkgUEdf
d3JpdGViYWNrIG9yDQo+IFBHX2RpcnR5KSwgaW4gbm9uLWtpbGxhYmxlIHNsZWVwcyBmb3IgdGhl
IG1vc3QgcGFydC4NCj4gDQo+IE1heWJlIHRoZSBmaXggaGVyZSBpcyBhcyBzaW1wbGUgYXMgY2hh
bmdpbmcgdGhhdD8NCg0KQXQgdGhlIHJpc2sgb2Yga2lja2luZyBvZmYgYW5vdGhlciBPX1BPTklF
UyBkaXNjdXNzaW9uOiBBZGQgYW4NCm9wZW4oT19USU1FT1VUKSBmbGFnIHRoYXQgd291bGQgbGV0
IHRoZSBrZXJuZWwga25vdyB0aGF0IHRoZQ0KYXBwbGljYXRpb24gaXMgcHJlcGFyZWQgdG8gaGFu
ZGxlIHRpbWVvdXRzIGZyb20gb3BlcmF0aW9ucyBzdWNoIGFzDQpyZWFkKCksIHdyaXRlKCkgYW5k
IGZzeW5jKCksIHRoZW4gYWRkIGFuIGlvY3RsKCkgb3Igc3lzY2FsbCB0byBhbGxvdw0Kc2FpZCBh
cHBsaWNhdGlvbiB0byBzZXQgdGhlIHRpbWVvdXQgdmFsdWUuDQoNCg0KLS0gDQpUcm9uZCBNeWts
ZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgUHJpbWFyeURhdGENCnRyb25kLm15
a2xlYnVzdEBwcmltYXJ5ZGF0YS5jb20NCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
