Date: Thu, 28 Feb 2008 15:20:44 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 04/21] free swap space on swap-in/activation
Message-ID: <20080228152044.218efa45@bree.surriel.com>
In-Reply-To: <1204229154.5301.22.camel@localhost>
References: <20080228192908.126720629@redhat.com>
	<20080228192928.251195952@redhat.com>
	<1204229154.5301.22.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Feb 2008 15:05:53 -0500
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> On Thu, 2008-02-28 at 14:29 -0500, Rik van Riel wrote:
> > plain text document attachment (rvr-00-linux-2.6-swapfree.patch)
> > + lts' convert anon_vma list lock to reader/write lock patch
> > + Nick Piggin's move and rework isolate_lru_page() patch
> 
> Hi, Rik:
> 
> We no long depend on the anon_vma rwlock patch, right?   And, since
> they're now all part of the same series, we can probably loose the note
> about depending on Nick's move/rework patch.  These are hold overs from
> my overly paranoid dependency annotations.  We can fix the description
> on next posting.  [Or am I being too pessimistic?]

Fixed the description for the next posting.  Thanks.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
