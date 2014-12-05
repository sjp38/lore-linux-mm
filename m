Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 5B6776B006E
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 05:22:47 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id eu11so449494pac.11
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 02:22:47 -0800 (PST)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id qg3si20718925pbb.8.2014.12.05.02.22.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Dec 2014 02:22:45 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Fri, 5 Dec 2014 18:22:33 +0800
Subject: RE: [RFC] mm:add KPF_ZERO_PAGE flag for /proc/kpageflags
Message-ID: <35FD53F367049845BC99AC72306C23D103E688B313F2@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E688B313EE@CNBJMBX05.corpusers.net>
 <CALYGNiOuBKz8shHSrFCp0BT5AV6XkNOCHj+LJedQQ-2YdZtM7w@mail.gmail.com>
In-Reply-To: <CALYGNiOuBKz8shHSrFCp0BT5AV6XkNOCHj+LJedQQ-2YdZtM7w@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Konstantin Khlebnikov' <koct9i@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBLb25zdGFudGluIEtobGVibmlr
b3YgW21haWx0bzprb2N0OWlAZ21haWwuY29tXQ0KPiBTZW50OiBGcmlkYXksIERlY2VtYmVyIDA1
LCAyMDE0IDU6MjEgUE0NCj4gVG86IFdhbmcsIFlhbGluDQo+IENjOiBsaW51eC1rZXJuZWxAdmdl
ci5rZXJuZWwub3JnOyBsaW51eC1tbUBrdmFjay5vcmc7IGxpbnV4LWFybS0NCj4ga2VybmVsQGxp
c3RzLmluZnJhZGVhZC5vcmc7IGFrcG1AbGludXgtZm91bmRhdGlvbi5vcmc7IG4tDQo+IGhvcmln
dWNoaUBhaC5qcC5uZWMuY29tDQo+IFN1YmplY3Q6IFJlOiBbUkZDXSBtbTphZGQgS1BGX1pFUk9f
UEFHRSBmbGFnIGZvciAvcHJvYy9rcGFnZWZsYWdzDQo+IA0KPiBPbiBGcmksIERlYyA1LCAyMDE0
IGF0IDExOjU3IEFNLCBXYW5nLCBZYWxpbiA8WWFsaW4uV2FuZ0Bzb255bW9iaWxlLmNvbT4NCj4g
d3JvdGU6DQo+ID4gVGhpcyBwYXRjaCBhZGQgS1BGX1pFUk9fUEFHRSBmbGFnIGZvciB6ZXJvX3Bh
Z2UsIHNvIHRoYXQgdXNlcnNwYWNlDQo+ID4gcHJvY2VzcyBjYW4gbm90aWNlIHplcm9fcGFnZSBm
cm9tIC9wcm9jL2twYWdlZmxhZ3MsIGFuZCB0aGVuIGRvIG1lbW9yeQ0KPiA+IGFuYWx5c2lzIG1v
cmUgYWNjdXJhdGVseS4NCj4gDQo+IEl0IHdvdWxkIGJlIG5pY2UgdG8gbWFyayBhbHNvIGh1Z2Vf
emVyb19wYWdlLiBTZWUgKGNvbXBsZXRlbHkNCj4gdW50ZXN0ZWQpIHBhdGNoIGluIGF0dGFjaG1l
bnQuDQo+IA0KR290IGl0LA0KVGhhbmtzIGZvciB5b3VyIHBhdGNoLg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
