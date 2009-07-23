Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D2F766B004D
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 07:43:33 -0400 (EDT)
Date: Thu, 23 Jul 2009 12:43:25 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 06/10] ksm: identify PageKsm pages
In-Reply-To: <20090723110655.f08cdcdc.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0907231236370.12896@sister.anvils>
References: <1247851850-4298-1-git-send-email-ieidus@redhat.com>
 <1247851850-4298-2-git-send-email-ieidus@redhat.com>
 <1247851850-4298-3-git-send-email-ieidus@redhat.com>
 <1247851850-4298-4-git-send-email-ieidus@redhat.com>
 <1247851850-4298-5-git-send-email-ieidus@redhat.com>
 <1247851850-4298-6-git-send-email-ieidus@redhat.com>
 <1247851850-4298-7-git-send-email-ieidus@redhat.com> <20090721175139.GE2239@random.random>
 <4A660101.3000307@redhat.com> <Pine.LNX.4.64.0907221346040.529@sister.anvils>
 <20090723110655.f08cdcdc.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <ieidus@redhat.com>, akpm@linux-foundation.org, chrisw@redhat.com, avi@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, 23 Jul 2009, KAMEZAWA Hiroyuki wrote:
> On Wed, 22 Jul 2009 13:54:06 +0100 (BST)
> Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:
> > 
> > (At this instant I've forgotten why there's an unevictable list at
> > all - somewhere in vmscan.c which is accustomed to dealing with
> > pages on lists, so easier to have them on a list than not?)
> > 
> I forget, too. But in short thinking, Unevictable pages should be
> on LRU (marked as PG_lru) for isolating page (from LRU) called by
> page migration etc.
> 
> isolate_lru_page()
> 	-> put page on private list
> 	-> do some work
> 	-> putback_lru_page()
> 
> sequence is useful at handling pages in a list.
> Because mlock/munclock can be called arbitrarily, unevicatable lru
> works enough good for making above kinds of code simpler.

Yes, I think that's it, thanks.

And for the moment, the KSM pages are therefore unmigratable
as well as unswappable; but that should change in 2.6.33.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
