Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id AC4636B0036
	for <linux-mm@kvack.org>; Fri,  3 Jan 2014 18:56:03 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id g10so15848092pdj.17
        for <linux-mm@kvack.org>; Fri, 03 Jan 2014 15:56:03 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id l8si47186865pao.65.2014.01.03.15.56.01
        for <linux-mm@kvack.org>;
        Fri, 03 Jan 2014 15:56:02 -0800 (PST)
Date: Fri, 3 Jan 2014 15:56:00 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/mlock: fix BUG_ON unlocked page for nolinear VMAs
Message-Id: <20140103155600.ce7194bb8b33d5581b05a162@linux-foundation.org>
In-Reply-To: <52C74972.6050909@suse.cz>
References: <1387267550-8689-1-git-send-email-liwanp@linux.vnet.ibm.com>
	<52b1138b.0201430a.19a8.605dSMTPIN_ADDED_BROKEN@mx.google.com>
	<52B11765.8030005@oracle.com>
	<52b120a5.a3b2440a.3acf.ffffd7c3SMTPIN_ADDED_BROKEN@mx.google.com>
	<52B166CF.6080300@suse.cz>
	<52b1699f.87293c0a.75d1.34d3SMTPIN_ADDED_BROKEN@mx.google.com>
	<20131218134316.977d5049209d9278e1dad225@linux-foundation.org>
	<52C71ACC.20603@oracle.com>
	<CA+55aFzDcFyyXwUUu5bLP3fsiuzxU7VPivpTPHgp8smvdTeESg@mail.gmail.com>
	<52C74972.6050909@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Michel Lespinasse <walken@google.com>, Bob Liu <bob.liu@oracle.com>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sat, 04 Jan 2014 00:36:18 +0100 Vlastimil Babka <vbabka@suse.cz> wrote:

> On 01/03/2014 09:52 PM, Linus Torvalds wrote:
> > On Fri, Jan 3, 2014 at 12:17 PM, Sasha Levin <sasha.levin@oracle.com> wrote:
> >>
> >> Ping? This BUG() is triggerable in 3.13-rc6 right now.
> > 
> > So Andrew suggested just removing the BUG_ON(), but it's been there
> > for a *long* time.
> 
> Yes, Andrew also merged this patch for that:
>  http://ozlabs.org/~akpm/mmots/broken-out/mm-remove-bug_on-from-mlock_vma_page.patch
> 
> But there wasn't enough confidence in the fix to sent it to you yet, I guess.
> 
> The related thread: http://www.spinics.net/lists/linux-mm/msg66972.html

Yes, I'd taken the cowardly approach of scheduling it for 3.14, with a
3.13.x backport.

Nobody answered my question!  Is this a new bug or is it a
five-year-old bug which we only just discovered?

I guess it doesn't matter much - we should fix it in 3.13.  I'll
include it in the next for-3.13 batch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
