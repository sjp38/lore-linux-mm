Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3B0D26B0035
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 04:02:18 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id et14so8140929pad.34
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 01:02:17 -0700 (PDT)
Received: from homiemail-a60.g.dreamhost.com (homie.mail.dreamhost.com. [208.97.132.208])
        by mx.google.com with ESMTP id zq1si10468477pac.44.2014.09.24.01.02.16
        for <linux-mm@kvack.org>;
        Wed, 24 Sep 2014 01:02:17 -0700 (PDT)
Message-ID: <1411545734.30630.4.camel@linux-t7sj.site>
Subject: Re: [PATCH 0/4] ipc/shm.c: increase the limits for SHMMAX, SHMALL
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Wed, 24 Sep 2014 10:02:14 +0200
In-Reply-To: <54210407.1000602@gmail.com>
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com>
	 <CAKgNAkjuU68hgyMOVGBVoBTOhhGdBytQh6H0ExiLoXfujKyP_w@mail.gmail.com>
	 <1401823560.4911.2.camel@buesod1.americas.hpqcorp.net>
	 <54210407.1000602@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Manfred Spraul <manfred@colorfullife.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, aswin@hp.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 2014-09-23 at 07:24 +0200, Michael Kerrisk (man-pages) wrote:
> David,
> 
> I applied various pieces from your patch on top of material
> that I already had, so that now we have the text below describing
> these limits.  Comments/suggestions/improvements from all welcome.

Looks good, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
