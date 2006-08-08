Message-ID: <44D7E7DF.1080106@yahoo.com.au>
Date: Tue, 08 Aug 2006 11:24:47 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: 2.6.18-rc3-mm2: rcu radix tree patches break page migration
References: <Pine.LNX.4.64.0608071556530.23088@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0608071556530.23088@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: npiggin@suse.de, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> If I take the following patches out then page migration works reliably 
> again. Otherwise page migration may result in weird values in the
> page struct. Reproduce by trying to migrate the executable pages
> of a running process. This usually creates enough races to break things.
> AFAIK the current radix tree rcu patches do not change the behavior
> of the tree_lock at all.
> 
> radix-tree-rcu-lockless-readside.patch
> redo-radix-tree-fixes.patch
> adix-tree-rcu-lockless-readside-update.patch
> radix-tree-rcu-lockless-readside-semicolon.patch
> adix-tree-rcu-lockless-readside-update-tidy.patch
> adix-tree-rcu-lockless-readside-fix-2.patch
> 
> Output in one failure scenario (after migrating the memory of cron back 
> and forth between nodes):

Yeah Lee noticed this as well...

Question: can you replace the lookup_slot with a regular lookup, then
replace the pointer switch with a radix_tree_delete + radix_tree_insert
and see if that works?

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
