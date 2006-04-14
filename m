Date: Thu, 13 Apr 2006 17:27:54 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/5] Swapless page migration V2: Overview
In-Reply-To: <20060413170853.0757af41.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0604131721340.15802@schroedinger.engr.sgi.com>
References: <20060413235406.15398.42233.sendpatchset@schroedinger.engr.sgi.com>
 <20060413170853.0757af41.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: hugh@veritas.com, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, linux-mm@kvack.org, taka@valinux.co.jp, marcelo.tosatti@cyclades.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, 13 Apr 2006, Andrew Morton wrote:

> > Currently page migration is depending on the ability to assign swap entries
> > to pages. However, those entries will only be to identify anonymous pages.
> > Page migration will not work without swap although swap space is never
> > really used.
> 
> That strikes me as a fairly minor limitation?

Some people want never ever to use swap. Systems that have no swap defined 
will currently not be able to migrate pages. Its kind of difficult to 
comprehend that you need to have swap for migration, but then its not 
going to be used. 

> > The patchset will allow later patches to enable migration of VM_LOCKED vmas,
> > the ability to exempt vmas from page migration, and allow the implementation
> > of a another userland migration API for handling batches of pages.
> 
> These seem like more important justifications.  Would you agree with that
> judgement?

The swapless thing is the most important for us because many of our 
customers do not have swap setup. Then follow the above 
features then the efficiency consideration.
 
> Is it not possible to implement some or all of these new things without
> this work?

VM_LOCKED semantics are that a page cannot be swapped out. Not being able 
to swap and not being able to migrate are the same right now. We need to 
separate both.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
