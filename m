Message-ID: <39122834.DA7FEDFF@sgi.com>
Date: Thu, 04 May 2000 18:47:32 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Re: 7-4 VM killing (A solution)
References: <Pine.LNX.4.21.0005042227540.28833-100000@duckman.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: Linus Torvalds <torvalds@transmeta.com>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 

> I've tried this variant (a few weeks ago, before submitting
> the current code to Linus) and have found a serious bug in
> it.
> 
> If we put all the unreferenced pages from one zone (with
> enough free pages) on the front of the queue, a subsequent
> run will not make it to the pages of the zone which needs
> to have pages freed currently...
> 

The only reason why pages should be moved to the tail
of the lru list is when they are referenced, and may be
if they have high page->count.

Pages in zones with enough free memory should not be re-ordered.
Such pages should not control the iterations of shrink_mmap.

The unreferenced pages currently at the front of the lru
queue are the ones that we should free first anyway. Just because
the corresponding zone has enough free memory in it, the
relative order does not change. Are you talking about these
pages adding up against "count" in shrink_mmap?

On a more practical note, how does your bug manifest?
What does not run, or does not run better?


-- 
--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
