Date: Thu, 15 Feb 2007 16:15:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] Remove unswappable anonymous pages off the LRU
Message-Id: <20070215161513.3a359cde.akpm@linux-foundation.org>
In-Reply-To: <1171581658.5114.76.camel@localhost>
References: <Pine.LNX.4.64.0702151300500.31366@schroedinger.engr.sgi.com>
	<45D4DF28.7070409@redhat.com>
	<Pine.LNX.4.64.0702151439520.32026@schroedinger.engr.sgi.com>
	<45D4E3B6.8050009@redhat.com>
	<1171581658.5114.76.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Rik van Riel <riel@redhat.com>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Martin J. Bligh" <mbligh@mbligh.org>, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Feb 2007 18:20:58 -0500
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> With the addition of Christoph's patch to move mlock()ed pages out of
> the LRU, we could add a mechanism to automagically lock shared memory
> regions that either exceed some tunable threshold or that exceed the
> available amount of swap.

But we have an out-of-band way of diddling shm segments?  So we could
create

	/usr/bin/ipclock --lock -i 2432

?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
