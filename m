Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id EDD046B007B
	for <linux-mm@kvack.org>; Sun,  3 Oct 2010 14:07:37 -0400 (EDT)
Date: Sun, 3 Oct 2010 13:07:31 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 7/9] v3 Define memory_block_size_bytes for
 powerpc/pseries
Message-ID: <20101003180731.GT14064@sgi.com>
References: <4CA62700.7010809@austin.ibm.com>
 <4CA62A0A.4050406@austin.ibm.com>
 <20101003175500.GE7896@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101003175500.GE7896@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Nathan Fontenot <nfont@austin.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Robin Holt <holt@sgi.com>, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

On Sun, Oct 03, 2010 at 11:25:00PM +0530, Balbir Singh wrote:
> * Nathan Fontenot <nfont@austin.ibm.com> [2010-10-01 13:35:54]:
> 
> > Define a version of memory_block_size_bytes() for powerpc/pseries such that
> > a memory block spans an entire lmb.
> 
> I hope I am not missing anything obvious, but why not just call it
> lmb_size, why do we need memblock_size?
> 
> Is lmb_size == memblock_size after your changes true for all
> platforms?

What is an lmb?  I don't recall anything like lmb being referred to in
the rest of the kernel.

Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
