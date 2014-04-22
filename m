Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id BECA86B006E
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 16:18:38 -0400 (EDT)
Received: by mail-ig0-f171.google.com with SMTP id c1so3477641igq.10
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 13:18:38 -0700 (PDT)
Received: from fujitsu25.fnanic.fujitsu.com (fujitsu25.fnanic.fujitsu.com. [192.240.6.15])
        by mx.google.com with ESMTPS id bo3si15856571icc.10.2014.04.22.13.18.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 13:18:37 -0700 (PDT)
From: Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>
Date: Tue, 22 Apr 2014 13:16:38 -0700
Subject: RE: [PATCH 3/4] ipc/shm.c: check for integer overflow during shmget.
Message-ID: <6B2BA408B38BA1478B473C31C3D2074E30989E9D81@SV-EXCHANGE1.Corp.FC.LOCAL>
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com>
	 <1398090397-2397-2-git-send-email-manfred@colorfullife.com>
	 <1398090397-2397-3-git-send-email-manfred@colorfullife.com>
	 <1398090397-2397-4-git-send-email-manfred@colorfullife.com>
 <1398190745.2473.10.camel@buesod1.americas.hpqcorp.net>
In-Reply-To: <1398190745.2473.10.camel@buesod1.americas.hpqcorp.net>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>, Manfred Spraul <manfred@colorfullife.com>
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Motohiro Kosaki JP <kosaki.motohiro@jp.fujitsu.com>, "gthelen@google.com" <gthelen@google.com>, "aswin@hp.com" <aswin@hp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

PiA+IFNITU1BWCBpcyB0aGUgdXBwZXIgbGltaXQgZm9yIHRoZSBzaXplIG9mIGEgc2hhcmVkIG1l
bW9yeSBzZWdtZW50LA0KPiA+IGNvdW50ZWQgaW4gYnl0ZXMuIFRoZSBhY3R1YWwgYWxsb2NhdGlv
biBpcyB0aGF0IHNpemUsIHJvdW5kZWQgdXAgdG8NCj4gPiB0aGUgbmV4dCBmdWxsIHBhZ2UuDQo+
ID4gQWRkIGEgY2hlY2sgdGhhdCBwcmV2ZW50cyB0aGUgY3JlYXRpb24gb2Ygc2VnbWVudHMgd2hl
cmUgdGhlIHJvdW5kZWQNCj4gPiB1cCBzaXplIGNhdXNlcyBhbiBpbnRlZ2VyIG92ZXJmbG93Lg0K
PiA+DQo+ID4gU2lnbmVkLW9mZi1ieTogTWFuZnJlZCBTcHJhdWwgPG1hbmZyZWRAY29sb3JmdWxs
aWZlLmNvbT4NCj4gDQo+IEFja2VkLWJ5OiBEYXZpZGxvaHIgQnVlc28gPGRhdmlkbG9ockBocC5j
b20+DQoNCkFja2VkLWJ5OiBLT1NBS0kgTW90b2hpcm8gPGtvc2FraS5tb3RvaGlyb0BqcC5mdWpp
dHN1LmNvbT4NCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
