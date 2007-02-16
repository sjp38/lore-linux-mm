Date: Thu, 15 Feb 2007 19:29:14 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Remove unswappable anonymous pages off the LRU
In-Reply-To: <45D52266.1040403@mbligh.org>
Message-ID: <Pine.LNX.4.64.0702151928480.1696@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702151300500.31366@schroedinger.engr.sgi.com>
 <20070215171355.67c7e8b4.akpm@linux-foundation.org> <45D50B79.5080002@mbligh.org>
 <Pine.LNX.4.64.0702151815230.1358@schroedinger.engr.sgi.com>
 <45D52266.1040403@mbligh.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Bligh <mbligh@mbligh.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Feb 2007, Martin Bligh wrote:

> > How would that work without a page flag? Without a flags there is no way of
> > checking that a page is on a particular list.
> 
> Depends what contexts you need to access it from. If you know the state
> before and after, list_del and list_add work.

What state before and after do you know?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
