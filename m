Date: Mon, 7 Jan 2008 10:18:01 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 00/19] VM pageout scalability improvements
Message-ID: <20080107101801.126cd709@bree.surriel.com>
In-Reply-To: <20080107190610.ed3be7b4.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080102224144.885671949@redhat.com>
	<1199379128.5295.21.camel@localhost>
	<20080103120000.1768f220@cuia.boston.redhat.com>
	<20080107190610.ed3be7b4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, 7 Jan 2008 19:06:10 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 3 Jan 2008 12:00:00 -0500
> Rik van Riel <riel@redhat.com> wrote:

> > If there is no swap space, my VM code will not bother scanning
> > any anon pages.  This has the same effect as moving the pages
> > to the no-reclaim list, with the extra benefit of being able to
> > resume scanning the anon lists once swap space is freed.
> > 
> Is this 'avoiding scanning anon if no swap' feature  in this set ?

I seem to have lost that code in a forward merge :(

Dunno if I started the forward merge from an older series that
Lee had or if I lost the code myself...

I'll put it back in ASAP.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
