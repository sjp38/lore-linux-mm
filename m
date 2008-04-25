Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3PJTitj014761
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 15:29:44 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3PJTiuS253174
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 15:29:44 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3PJThIp019968
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 15:29:44 -0400
Date: Fri, 25 Apr 2008 12:29:42 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 02/18] hugetlb: factor out huge_new_page
Message-ID: <20080425192942.GB14623@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015429.834926000@nick.local0.net> <20080424235431.GB4741@us.ibm.com> <20080424235829.GC4741@us.ibm.com> <481183FC.9060408@firstfloor.org> <20080425165424.GA9680@us.ibm.com> <Pine.LNX.4.64.0804251210530.5971@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804251210530.5971@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 25.04.2008 [12:13:19 -0700], Christoph Lameter wrote:
> On Fri, 25 Apr 2008, Nishanth Aravamudan wrote:
> 
> > > >>> This happens to fix a minor bug. When alloc_bootmem_node returns
> > > >>> a fallback node on a different node than passed the old code
> > > >>> would have put it into the free lists of the wrong node.
> > > >>> Now it would end up in the freelist of the correct node.
> > > >> This is rather frustrating. The whole point of having the __GFP_THISNODE
> > > >> flag is to indicate off-node allocations are *not* supported from the
> > > >> caller... This was all worked on quite heavily a while back.
> > > 
> > > Perhaps it was, but the result in hugetlb.c was not correct.
> > 
> > Huh? There is a case in current code (current hugepage sizes) that
> > allows __GFP_THISNODE to go off-node?
> 
> Argh. Danger. SLAB will crash and/or corrupt data if that occurs.
> 
> > > No, the bug is already there even without the bootmem patch.
> > 
> > Where does alloc_pages_node go off-node? It is a bug in the core VM if
> > it does, as we decided __GFP_THISNODE semantics with a nid specified
> > indicates *no* fallback should occur.
> 
> But this is only for bootmem right? SLAB is not using bootmem so we could 
> make an exception there. The issue is support of __GFP_THISNODE in the 
> bootmem allocator?

I think so -- I'm not entirely sure. Andi, can you elucidate?

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
