Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f51.google.com (mail-yh0-f51.google.com [209.85.213.51])
	by kanga.kvack.org (Postfix) with ESMTP id CFE936B0036
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 17:50:31 -0500 (EST)
Received: by mail-yh0-f51.google.com with SMTP id c41so10372320yho.24
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 14:50:31 -0800 (PST)
Date: Wed, 04 Dec 2013 17:50:28 -0500 (EST)
Message-Id: <20131204.175028.1602944177771517327.davem@davemloft.net>
Subject: Re: 2e685cad5790 build warning
From: David Miller <davem@davemloft.net>
In-Reply-To: <20131204222943.GC21724@cmpxchg.org>
References: <20131204222943.GC21724@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: ebiederm@xmission.com, glommer@gmail.com, netdev@vger.kernel.org, linux-mm@kvack.org, linux-kernel@kvack.org

RnJvbTogSm9oYW5uZXMgV2VpbmVyIDxoYW5uZXNAY21weGNoZy5vcmc+DQpEYXRlOiBXZWQsIDQg
RGVjIDIwMTMgMTc6Mjk6NDMgLTA1MDANCg0KPiBsaW51eC9uZXQvaXB2NC90Y3BfbWVtY29udHJv
bC5jOjk6MTM6IHdhcm5pbmc6IKFtZW1jZ190Y3BfZW50ZXJfbWVtb3J5X3ByZXNzdXJloiBkZWZp
bmVkIGJ1dCBub3QgdXNlZCBbLVd1bnVzZWQtZnVuY3Rpb25dDQo+ICBzdGF0aWMgdm9pZCBtZW1j
Z190Y3BfZW50ZXJfbWVtb3J5X3ByZXNzdXJlKHN0cnVjdCBzb2NrICpzaykNCg0KQWxzbywgYW11
c2luZ2x5LCBhbHRob3VnaCBzdGF0aWMgdGhlcmUgaXMgYW4gRVhQT1JUX1NZTUJPTCgpIGZvciBp
dC4NCg0KPiANCj4gSSBjYW4gbm90IHNlZSBmcm9tIHRoZSBjaGFuZ2Vsb2cgd2h5IHRoaXMgZnVu
Y3Rpb24gaXMgbm8gbG9uZ2VyIHVzZWQsDQo+IG9yIHdobyBpcyBzdXBwb3NlZCB0byBub3cgc2V0
IGNnX3Byb3RvLT5tZW1vcnlfcHJlc3N1cmUgd2hpY2ggeW91DQo+IHN0aWxsIGluaXRpYWxpemUg
ZXRjLiAgRWl0aGVyIHdheSwgdGhlIGN1cnJlbnQgc3RhdGUgZG9lcyBub3Qgc2VlbSB0bw0KPiBt
YWtlIG11Y2ggc2Vuc2UuICBUaGUgYXV0aG9yIHdvdWxkIGJlIHRoZSBiZXN0IHBlcnNvbiB0byBk
b3VibGUgY2hlY2sNCj4gc3VjaCBjaGFuZ2VzLCBidXQgaGUgd2Fzbid0IGNvcGllZCBvbiB5b3Vy
IHBhdGNoLCBzbyBJIGNvcGllZCBoaW0gbm93Lg0KDQpFcmljLCBwbGVhc2UgcmVzb2x2ZSB0aGlz
Lg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
