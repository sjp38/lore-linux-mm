From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14202.21461.422665.925464@dukat.scot.redhat.com>
Date: Wed, 30 Jun 1999 18:28:53 +0100 (BST)
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8 Fix swapoff races
In-Reply-To: <199906292201.PAA17715@google.engr.sgi.com>
References: <14200.45499.255924.339550@dukat.scot.redhat.com>
	<199906292201.PAA17715@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, andrea@suse.de, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 29 Jun 1999 15:01:24 -0700 (PDT), kanoj@google.engr.sgi.com
(Kanoj Sarcar) said:

> To know whether there are any more references left to be eliminated
> on a swap page, we can not tolerate a SWAP_MAP_MAX concept; else we
> can never determine whether there are processes still referencing the
> swap page. Removing SWAP_MAP_MAX is a good thing in itself. The 
> swap_map[] array needs to be declared as an array of elements of the 
> same size as the page->count field, ie an atomic_t (since there can be
> no more references to the swap page than there can be on the physical
> page).

Yes there can...

> Also, I am not sure why you say that fork can not keep ahead of
> the swapoff sweep forever. 

Hmm, maybe..

> Are you saying it is okay not to guarantee forward progress of swapoff
> while a program that keeps on forking (and the children exit almost
> immediately) is running? 

There are a lot of things which don't make forward progress in such a
situation already.  Put a lock on dup_mm() if it worries you that much.

> Then there's the complexity of clone(CLONE_PID), which creates task
> structures with the same pid, so the pid fencepost algorithm would
> need to handle that too ...

Sure.  I never said that I had a complete solution: I just don't believe
that a new mm lock on all the faulting paths is necessary for a complete
solution.  

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
