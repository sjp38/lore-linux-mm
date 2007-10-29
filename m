Date: Mon, 29 Oct 2007 21:07:34 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC] [-mm PATCH] Memory controller fix swap charging context
 in unuse_pte()
In-Reply-To: <20071028203219.GA7145@linux.vnet.ibm.com>
Message-ID: <Pine.LNX.4.64.0710292101510.23980@blonde.wat.veritas.com>
References: <20071005041406.21236.88707.sendpatchset@balbir-laptop>
 <Pine.LNX.4.64.0710071735530.13138@blonde.wat.veritas.com>
 <4713A2F2.1010408@linux.vnet.ibm.com> <Pine.LNX.4.64.0710221933570.21262@blonde.wat.veritas.com>
 <471F3732.5050407@linux.vnet.ibm.com> <Pine.LNX.4.64.0710252002540.25735@blonde.wat.veritas.com>
 <4724F0BC.1020209@linux.vnet.ibm.com> <20071028203219.GA7145@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Linux Containers <containers@lists.osdl.org>, Linux MM Mailing List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Oct 2007, Balbir Singh wrote:
> On Mon, Oct 29, 2007 at 01:57:40AM +0530, Balbir Singh wrote:
> Hugh Dickins wrote:
> 
> [snip]
>  
> > Without your mem_cgroup mods in mm/swap_state.c, unuse_pte makes
> > the right assignments (I believe).  But I find that swapout (using
> > 600M in a 512M machine) from a 200M cgroup quickly OOMs, whereas
> > it behaves correctly with your mm/swap_state.c.
> > 
> 
> On my UML setup, I booted the UML instance with 512M of memory and
> used the swapout program that you shared. I tried two things
> 
> 
> 1. Ran swapout without any changes. The program ran well without
>    any OOM condition occuring, lot of reclaim occured.
> 2. Ran swapout with the changes to mm/swap_state.c removed (diff below)
>    and I still did not see any OOM. The reclaim count was much lesser
>    since swap cache did not get accounted back to the cgroup from
>    which pages were being evicted.
> 
> I am not sure why I don't see the OOM that you see, still trying. May be
> I missing something obvious at this late hour in the night :-)

I reconfirm that I do see those OOMs.  I'll have to try harder to
analyze how they come about: I sure don't expect you to debug a
problem you cannot reproduce.  But what happens if you try it
native rather than using UML?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
