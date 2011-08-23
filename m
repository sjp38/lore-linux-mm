Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6A73F6B0169
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 11:26:43 -0400 (EDT)
Received: by qwd6 with SMTP id 6so207932qwd.14
        for <linux-mm@kvack.org>; Tue, 23 Aug 2011 08:26:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110822134348.a57db0e1.akpm@linux-foundation.org>
References: <1314030548-21082-1-git-send-email-akinobu.mita@gmail.com>
	<1314030548-21082-3-git-send-email-akinobu.mita@gmail.com>
	<20110822134348.a57db0e1.akpm@linux-foundation.org>
Date: Wed, 24 Aug 2011 00:26:41 +0900
Message-ID: <CAC5umygVhjAAH-o_KGp+hkHeqfGpX9J+GP8aS68H_=GSLEdNWg@mail.gmail.com>
Subject: Re: [PATCH 2/4] debug-pagealloc: add support for highmem pages
From: Akinobu Mita <akinobu.mita@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

2011/8/23 Andrew Morton <akpm@linux-foundation.org>:

> This seems more complicated than is needed. =A0Couldn't we just do
>
> static void poison_page(struct page *page)
> {
> =A0 =A0 =A0 =A0void *addr;
>
> =A0 =A0 =A0 =A0preempt_disable();
> =A0 =A0 =A0 =A0addr =3D kmap_atomic(page);
> =A0 =A0 =A0 =A0set_page_poison(page);
> =A0 =A0 =A0 =A0memset(addr, PAGE_POISON, PAGE_SIZE);
> =A0 =A0 =A0 =A0kunmap_atomic(addr);
> =A0 =A0 =A0 =A0preempt_enable();
> }
>
> ?

This code looks much better.  I'll update the patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
