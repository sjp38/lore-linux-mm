Date: Fri, 28 Apr 2006 17:46:22 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/7] page migration: Reorder functions in migrate.c
In-Reply-To: <20060428173650.146a6605.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0604281744270.4378@schroedinger.engr.sgi.com>
References: <20060428060302.30257.76871.sendpatchset@schroedinger.engr.sgi.com>
 <20060428150806.057b0bac.akpm@osdl.org> <Pine.LNX.4.64.0604281556220.3412@schroedinger.engr.sgi.com>
 <20060428161830.7af8c3f0.akpm@osdl.org> <Pine.LNX.4.64.0604281712210.4170@schroedinger.engr.sgi.com>
 <20060428173650.146a6605.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, lee.schermerhorn@hp.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Fri, 28 Apr 2006, Andrew Morton wrote:

> hm.  migrate_pages() locks two pages at the same time.  We've avoided doing
> that.
> 
> a) what prevents ab/ba deadlocks in the migration code?

Nothing right now.


> b) if some other part of the kernel later decides to lock two pages at
>    the same time, what protocol should that code follow to avoid ab/ba
>    deadlocks?   lowest-pfn-first might be one.

We could just do a TestSetPageLocked() on the newpage. If it fails then we 
postphone migration to the next loop. 

Patch on top of the one i just sent you or after the cleanup patches?

 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
