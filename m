From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906282343.QAA02075@google.engr.sgi.com>
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8 Fix swapoff races
Date: Mon, 28 Jun 1999 16:43:59 -0700 (PDT)
In-Reply-To: <14199.62272.298499.628883@dukat.scot.redhat.com> from "Stephen C. Tweedie" at Jun 28, 99 11:12:16 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: andrea@suse.de, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> Hi,
> 
> On Mon, 28 Jun 1999 14:11:18 -0700 (PDT), kanoj@google.engr.sgi.com
> (Kanoj Sarcar) said:
> 
> > If I understand right, here is an example. Lets say I believe I 
> > have scanned uptil pid 10. You are suggesting, after having scanned
> > pid 10, hold on to task_lock, and look for the min pid > 10. Say
> > that is pid 12. Problem is, while I was scanning pid 10, maybe
> > pid 5 got reallocated, and pid 5 is a new process (probably a 
> > child of pid 20). 
> 
> Fine --- repeat the whole thing until we have no swap entries left.  We
> can still guarantee to make progress without extra locking for normal
> swapping. 
>

This will almost always work, except theoretically, you still can
not guarantee forward progress, unless you can stop forks() from
happening. That is, given a high enough rate of forking, swapoff
is never going to terminate. 

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
