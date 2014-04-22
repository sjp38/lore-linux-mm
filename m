Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f43.google.com (mail-yh0-f43.google.com [209.85.213.43])
	by kanga.kvack.org (Postfix) with ESMTP id 109716B0072
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 16:19:02 -0400 (EDT)
Received: by mail-yh0-f43.google.com with SMTP id b6so5303716yha.2
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 13:19:01 -0700 (PDT)
Received: from fujitsu24.fnanic.fujitsu.com (fujitsu24.fnanic.fujitsu.com. [192.240.6.14])
        by mx.google.com with ESMTPS id f1si8552908yhh.103.2014.04.22.13.19.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 13:19:01 -0700 (PDT)
From: Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>
Date: Tue, 22 Apr 2014 13:16:11 -0700
Subject: RE: [PATCH 2/4] ipc/shm.c: check for overflows of shm_tot
Message-ID: <6B2BA408B38BA1478B473C31C3D2074E30989E9D7E@SV-EXCHANGE1.Corp.FC.LOCAL>
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com>
	 <1398090397-2397-2-git-send-email-manfred@colorfullife.com>
	 <1398090397-2397-3-git-send-email-manfred@colorfullife.com>
 <1398190732.2473.9.camel@buesod1.americas.hpqcorp.net>
In-Reply-To: <1398190732.2473.9.camel@buesod1.americas.hpqcorp.net>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>, Manfred Spraul <manfred@colorfullife.com>
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Motohiro Kosaki JP <kosaki.motohiro@jp.fujitsu.com>, "gthelen@google.com" <gthelen@google.com>, "aswin@hp.com" <aswin@hp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

PiA+IHNobV90b3QgY291bnRzIHRoZSB0b3RhbCBudW1iZXIgb2YgcGFnZXMgdXNlZCBieSBzaG0g
c2VnbWVudHMuDQo+ID4NCj4gPiBJZiBTSE1BTEwgaXMgVUxPTkdfTUFYIChvciBuZWFybHkgVUxP
TkdfTUFYKSwgdGhlbiB0aGUgbnVtYmVyIGNhbg0KPiA+IG92ZXJmbG93LiAgU3Vic2VxdWVudCBj
YWxscyB0byBzaG1jdGwoLFNITV9JTkZPLCkgd291bGQgcmV0dXJuIHdyb25nDQo+ID4gdmFsdWVz
IGZvciBzaG1fdG90Lg0KPiA+DQo+ID4gVGhlIHBhdGNoIGFkZHMgYSBkZXRlY3Rpb24gZm9yIG92
ZXJmbG93cy4NCj4gPg0KPiA+IFNpZ25lZC1vZmYtYnk6IE1hbmZyZWQgU3ByYXVsIDxtYW5mcmVk
QGNvbG9yZnVsbGlmZS5jb20+DQo+IA0KPiBBY2tlZC1ieTogRGF2aWRsb2hyIEJ1ZXNvIDxkYXZp
ZGxvaHJAaHAuY29tPg0KDQpBY2tlZC1ieTogS09TQUtJIE1vdG9oaXJvIDxrb3Nha2kubW90b2hp
cm9AanAuZnVqaXRzdS5jb20+DQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
