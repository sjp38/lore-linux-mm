Date: Thu, 1 Mar 2007 17:48:32 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Remove page flags for software suspend
In-Reply-To: <45E6EEC5.4060902@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0703011744500.11812@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com>
 <20070228101403.GA8536@elf.ucw.cz> <Pine.LNX.4.64.0702280724540.16552@schroedinger.engr.sgi.com>
 <200702281813.04643.rjw@sisk.pl> <45E6EEC5.4060902@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Christoph Lameter <clameter@engr.sgi.com>, Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 1 Mar 2007, Nick Piggin wrote:
> 
> Let's make sure that no more backdoor page flags get allocated without
> going through the linux-mm list to work out whether we really need it
> or can live without it...

On Fri, 2 Mar 2007, Nick Piggin wrote:
> 
> I need one bit for lockless pagecache ;)

Is that still your PageNoNewRefs thing?
What was wrong with my atomic_cmpxchg suggestion?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
