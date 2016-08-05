Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9BF4C828E1
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 11:36:16 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 1so20092882wmz.2
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 08:36:16 -0700 (PDT)
Received: from smtp-out6.electric.net (smtp-out6.electric.net. [192.162.217.187])
        by mx.google.com with ESMTPS id g14si8019131ljg.42.2016.08.05.08.36.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Aug 2016 08:36:14 -0700 (PDT)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: order-0 vs order-N driver allocation. Was: [PATCH v10 07/12]
 net/mlx4_en: add page recycle to prepare rx ring for tx support
Date: Fri, 5 Aug 2016 15:33:27 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F50B52E@AcuExch.aculab.com>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
 <1468955817-10604-8-git-send-email-bblanco@plumgrid.com>
 <1469432120.8514.5.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160803174107.GA38399@ast-mbp.thefacebook.com>
 <20160804181913.26ee17b9@redhat.com>
 <CAKgT0UdbVK6Ti9drCQFfa0MyU40Kh=Hu=BtDTRCqqsSiBvJ7rg@mail.gmail.com>
 <20160805035534.GA56390@ast-mbp.thefacebook.com>
 <CAKgT0Uc0=10xhcJJ+55rBv=YNPgPLmHb8x82CKbj+N895JQY5Q@mail.gmail.com>
In-Reply-To: <CAKgT0Uc0=10xhcJJ+55rBv=YNPgPLmHb8x82CKbj+N895JQY5Q@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Alexander Duyck' <alexander.duyck@gmail.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Brenden Blanco <bblanco@plumgrid.com>, David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>, Jamal Hadi Salim <jhs@mojatatu.com>, Saeed Mahameed <saeedm@dev.mellanox.co.il>, Martin
 KaFai Lau <kafai@fb.com>, Ari Saha <as754m@att.com>, Or Gerlitz <gerlitz.or@gmail.com>, john fastabend <john.fastabend@gmail.com>, Hannes
 Frederic Sowa <hannes@stressinduktion.org>, Thomas Graf <tgraf@suug.ch>, Tom Herbert <tom@herbertland.com>, Daniel Borkmann <daniel@iogearbox.net>, Tariq Toukan <ttoukan.linux@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

RnJvbTogQWxleGFuZGVyIER1eWNrDQo+IFNlbnQ6IDA1IEF1Z3VzdCAyMDE2IDE2OjE1DQouLi4N
Cj4gPg0KPiA+IGludGVyZXN0aW5nIGlkZWEuIExpa2UgZG1hX21hcCAxR0IgcmVnaW9uIGFuZCB0
aGVuIGFsbG9jYXRlDQo+ID4gcGFnZXMgZnJvbSBpdCBvbmx5PyBidXQgdGhlIHJlc3Qgb2YgdGhl
IGtlcm5lbCB3b24ndCBiZSBhYmxlDQo+ID4gdG8gdXNlIHRoZW0/IHNvIG9ubHkgc29tZSBzbWFs
bGVyIHJlZ2lvbiB0aGVuPyBvciBpdCB3aWxsIGJlDQo+ID4gYSBib290IHRpbWUgZmxhZyB0byBy
ZXNlcnZlIHRoaXMgcHNldWRvLWh1Z2UgcGFnZT8NCj4gDQo+IFllYWgsIHNvbWV0aGluZyBsaWtl
IHRoYXQuICBJZiB3ZSB3ZXJlIGFscmVhZHkgdGFsa2luZyBhYm91dA0KPiBhbGxvY2F0aW5nIGEg
cG9vbCBvZiBwYWdlcyBpdCBtaWdodCBtYWtlIHNlbnNlIHRvIGp1c3Qgc2V0dXAgc29tZXRoaW5n
DQo+IGxpa2UgdGhpcyB3aGVyZSB5b3UgY291bGQgcmVzZXJ2ZSBhIDFHQiByZWdpb24gZm9yIGEg
c2luZ2xlIDEwRyBkZXZpY2UNCj4gZm9yIGluc3RhbmNlLiAgVGhlbiBpdCB3b3VsZCBtYWtlIHRo
ZSB3aG9sZSB0aGluZyBtdWNoIGVhc2llciB0byBkZWFsDQo+IHdpdGggc2luY2UgeW91IHdvdWxk
IGhhdmUgYSBibG9jayBvZiBtZW1vcnkgdGhhdCBzaG91bGQgcGVyZm9ybSB2ZXJ5DQo+IHdlbGwg
aW4gdGVybXMgb2YgRE1BIGFjY2Vzc2VzLg0KDQpJU1RNIHRoYXQgdGhlIG1haW4ga2VybmVsIGFs
bG9jYXRvciBvdWdodCB0byBiZSBrZWVwaW5nIGEgY2FjaGUNCm9mIHBhZ2VzIHRoYXQgYXJlIG1h
cHBlZCBpbnRvIHRoZSB2YXJpb3VzIElPTU1VLg0KVGhpcyBtaWdodCBiZSBhIHBlci1kcml2ZXIg
Y2FjaGUsIGJ1dCBjb3VsZCBiZSBtdWNoIHdpZGVyLg0KDQpUaGVuIGlmIHNvbWUgY29kZSB3YW50
cyBzdWNoIGEgcGFnZSBpdCBjYW4gYmUgYWxsb2NhdGVkIG9uZSB0aGF0IGlzDQphbHJlYWR5IG1h
cHBlZC4NClVuZGVyIG1lbW9yeSBwcmVzc3VyZSB0aGUgcGFnZXMgY291bGQgdGhlbiBiZSByZXVz
ZWQgZm9yIG90aGVyIHB1cnBvc2VzLg0KDQouLi4NCj4gSW4gdGhlIEludGVsIGRyaXZlcnMgZm9y
IGluc3RhbmNlIGlmIHRoZSBmcmFtZQ0KPiBzaXplIGlzIGxlc3MgdGhhbiAyNTYgYnl0ZXMgd2Ug
anVzdCBjb3B5IHRoZSB3aG9sZSB0aGluZyBvdXQgc2luY2UgaXQNCj4gaXMgY2hlYXBlciB0byBq
dXN0IGV4dGVuZCB0aGUgaGVhZGVyIGNvcHkgcmF0aGVyIHRoYW4gdGFraW5nIHRoZSBleHRyYQ0K
PiBoaXQgZm9yIGdldF9wYWdlL3B1dF9wYWdlLg0KDQpIb3cgZmFzdCBpcyAncmVwIG1vdnNiJyAo
b24gY2FjaGVkIGFkZHJlc3Nlcykgb24gcmVjZW50IHg4NiBjcHU/DQpJdCBtaWdodCBhY3R1YWxs
eSBiZSB3b3J0aCB1bmNvbmRpdGlvbmFsbHkgY29weWluZyB0aGUgZW50aXJlIGZyYW1lDQpvbiB0
aG9zZSBjcHVzLg0KDQpBIGxvbmcgdGltZSBhZ28gd2UgZm91bmQgdGhlIGJyZWFrZXZlbiBwb2lu
dCBmb3IgdGhlIGNvcHkgdG8gYmUgYWJvdXQNCjFrYiBvbiBzcGFyYyBtYnVzL3NidXMgc3lzdGVt
cyAtIGFuZCB0aGF0IG1pZ2h0IG5vdCBoYXZlIGJlZW4gYWxpZ25pbmcNCnRoZSBjb3B5Lg0KDQoJ
RGF2aWQNCg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
