Date: Thu, 15 Feb 2007 07:15:57 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 7/7] Opportunistically move mlocked pages off the LRU
In-Reply-To: <20070215133936.47ca3640.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0702150715170.10403@schroedinger.engr.sgi.com>
References: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
 <20070215012525.5343.71985.sendpatchset@schroedinger.engr.sgi.com>
 <20070215133936.47ca3640.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: akpm@osdl.org, hch@infradead.org, a.p.zijlstra@chello.nl, mbligh@mbligh.org, arjan@infradead.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org, mpm@selenic.com, nigel@nigel.suspend2.net, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, 15 Feb 2007, KAMEZAWA Hiroyuki wrote:

> > +	if (vma->vm_flags & VM_LOCKED)
> > +		try_to_set_mlocked(page);
> 
> if (page != ZERO_PAGE(addres) && vma->vm_flags & VM_LOCKED)
> 		try_to_set_mlocked(pages);
> 
> 
> I'm sorry if I misunderstand how ZERO_PAGE works.

Zero Pages are not on the LRU so try_to_set_mlocked will fail.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
