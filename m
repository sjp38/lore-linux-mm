From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14200.45499.255924.339550@dukat.scot.redhat.com>
Date: Tue, 29 Jun 1999 12:44:59 +0100 (BST)
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8 Fix swapoff races
In-Reply-To: <199906282343.QAA02075@google.engr.sgi.com>
References: <14199.62272.298499.628883@dukat.scot.redhat.com>
	<199906282343.QAA02075@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, andrea@suse.de, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 28 Jun 1999 16:43:59 -0700 (PDT), kanoj@google.engr.sgi.com
(Kanoj Sarcar) said:

> This will almost always work, except theoretically, you still can
> not guarantee forward progress, unless you can stop forks() from
> happening. That is, given a high enough rate of forking, swapoff
> is never going to terminate. 

Then repeat until it converges, ie. until you have no swap entries left.
No big deal.  Unless the swapoff sweep and the fork are running over pid
space at exactly the same rate forever (which we do not have to worry
about!), you will make progress.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
