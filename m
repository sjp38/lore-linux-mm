Date: Mon, 7 Jan 2008 11:49:55 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: RFC/Patch Make Page Tables Relocatable Part 2/2 Page Table
 Migration Code
In-Reply-To: <d43160c70801040802p2a6d96c8p406eb391cbd829e4@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0801071149160.23617@schroedinger.engr.sgi.com>
References: <d43160c70801040802p2a6d96c8p406eb391cbd829e4@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ross Biro <rossb@google.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 4 Jan 2008, Ross Biro wrote:

> Here is the code to do the actual relocation.  I believe there is a
> race in this version of the code.  If the relocation code sleeps while
> allocating memory and the rcu code frees the old page tables before
> the tlbflush, then if another cpu is running the process in user
> space, the page tables could be corrupted.  Not really a big deal, but
> it needs to be fixed.  Probably by not scheduling the rcu free until
> after all the page tables have been relocated.

Interesting approach. It moves all page table pages even if only a subset 
of the address space was migrated?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
