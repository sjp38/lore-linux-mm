Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4C80C6B006A
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 08:18:14 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 22so327030fge.8
        for <linux-mm@kvack.org>; Tue, 19 Jan 2010 05:18:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1263905332.2163.11.camel@barrios-desktop>
References: <20100118141938.GI30698@redhat.com>
	 <20100118181942.GD22111@redhat.com>
	 <20100118191031.0088f49a@lxorguk.ukuu.org.uk>
	 <20100119071734.GG14345@redhat.com>
	 <84144f021001182337o274c8ed3q8ce60581094bc2b9@mail.gmail.com>
	 <20100119075205.GI14345@redhat.com>
	 <84144f021001190007q54a334dfwed64189e6cf0b7c4@mail.gmail.com>
	 <20100119082638.GK14345@redhat.com>
	 <84144f021001190044s397c6665qb00af48235d2d818@mail.gmail.com>
	 <1263905332.2163.11.camel@barrios-desktop>
Date: Tue, 19 Jan 2010 15:18:11 +0200
Message-ID: <84144f021001190518x450868eax2edfa5e16ff6e4b@mail.gmail.com>
Subject: Re: [PATCH v6] add MAP_UNLOCKED mmap flag
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Gleb Natapov <gleb@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, andrew.c.morrow@gmail.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 19, 2010 at 2:48 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> Gleb. How about using MADV_SEQUENTIAL on guest memory?
> It makes that pages of guest are moved into inactive reclaim list more
> fast. It means it is likely to swap out faster than other pages if it
> isn't hit during inactive list.

Yeah, something like that but we don't want the readahead. OTOH, it's
not clear what Gleb's real problem is. Are the guest address spaces
anonymous or file backed? Which parts of the emulator are swapped out
that are causing the problem? Maybe it's a VM balancing issue that
mlock papers over?

                         Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
