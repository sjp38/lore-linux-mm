Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A3FA36B008C
	for <linux-mm@kvack.org>; Sun,  3 Oct 2010 14:27:05 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o93IBJgR001804
	for <linux-mm@kvack.org>; Sun, 3 Oct 2010 14:11:19 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o93IR3mI079018
	for <linux-mm@kvack.org>; Sun, 3 Oct 2010 14:27:03 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o93IR3LC026904
	for <linux-mm@kvack.org>; Sun, 3 Oct 2010 14:27:03 -0400
Date: Sun, 3 Oct 2010 23:57:01 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 7/9] v3 Define memory_block_size_bytes for powerpc/pseries
Message-ID: <20101003182701.GI7896@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <4CA62700.7010809@austin.ibm.com>
 <4CA62A0A.4050406@austin.ibm.com>
 <20101003175500.GE7896@balbir.in.ibm.com>
 <20101003180731.GT14064@sgi.com>
 <1286129461.9970.1.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1286129461.9970.1.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Robin Holt <holt@sgi.com>, Nathan Fontenot <nfont@austin.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Greg KH <greg@kroah.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

* Dave Hansen <dave@linux.vnet.ibm.com> [2010-10-03 11:11:01]:

> On Sun, 2010-10-03 at 13:07 -0500, Robin Holt wrote:
> > On Sun, Oct 03, 2010 at 11:25:00PM +0530, Balbir Singh wrote:
> > > * Nathan Fontenot <nfont@austin.ibm.com> [2010-10-01 13:35:54]:
> > > 
> > > > Define a version of memory_block_size_bytes() for powerpc/pseries such that
> > > > a memory block spans an entire lmb.
> > > 
> > > I hope I am not missing anything obvious, but why not just call it
> > > lmb_size, why do we need memblock_size?
> > > 
> > > Is lmb_size == memblock_size after your changes true for all
> > > platforms?
> > 
> > What is an lmb?  I don't recall anything like lmb being referred to in
> > the rest of the kernel.
> 
> Heh.  It's the OpenFirmware name for a Logical Memory Block.  Basically
> what we use to determine the SECTION_SIZE on powerpc.  Probably not the
> best terminology to use elsewhere in the kernel.

Agreed for the kernel, this patch was for powerpc/pseries, hence was
checking in this context.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
