Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id D1DA16B0070
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 16:18:54 -0400 (EDT)
Received: by mail-ig0-f178.google.com with SMTP id hn18so139819igb.11
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 13:18:54 -0700 (PDT)
Received: from fujitsu24.fnanic.fujitsu.com (fujitsu24.fnanic.fujitsu.com. [192.240.6.14])
        by mx.google.com with ESMTPS id rv8si13475948igb.32.2014.04.22.13.18.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 13:18:54 -0700 (PDT)
From: Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>
Date: Tue, 22 Apr 2014 13:15:44 -0700
Subject: RE: [PATCH 1/4] ipc/shm.c: check for ulong overflows in shmat
Message-ID: <6B2BA408B38BA1478B473C31C3D2074E30989E9D7A@SV-EXCHANGE1.Corp.FC.LOCAL>
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com>
	 <1398090397-2397-2-git-send-email-manfred@colorfullife.com>
 <1398190717.2473.8.camel@buesod1.americas.hpqcorp.net>
In-Reply-To: <1398190717.2473.8.camel@buesod1.americas.hpqcorp.net>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>, Manfred Spraul <manfred@colorfullife.com>
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Motohiro Kosaki JP <kosaki.motohiro@jp.fujitsu.com>, "gthelen@google.com" <gthelen@google.com>, "aswin@hp.com" <aswin@hp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

PiA+IGZpbmRfdm1hX2ludGVyc2VjdGlvbiBkb2VzIG5vdCB3b3JrIGFzIGludGVuZGVkIGlmIGFk
ZHIrc2l6ZSBvdmVyZmxvd3MuDQo+ID4gVGhlIHBhdGNoIGFkZHMgYSBtYW51YWwgY2hlY2sgYmVm
b3JlIHRoZSBjYWxsIHRvIGZpbmRfdm1hX2ludGVyc2VjdGlvbi4NCj4gPg0KPiA+IFNpZ25lZC1v
ZmYtYnk6IE1hbmZyZWQgU3ByYXVsIDxtYW5mcmVkQGNvbG9yZnVsbGlmZS5jb20+DQo+IA0KPiBB
Y2tlZC1ieTogRGF2aWRsb2hyIEJ1ZXNvIDxkYXZpZGxvaHJAaHAuY29tPg0KDQpBY2tlZC1ieTog
S09TQUtJIE1vdG9oaXJvIDxrb3Nha2kubW90b2hpcm9AanAuZnVqaXRzdS5jb20+DQoNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
