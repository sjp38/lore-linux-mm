Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3E5C16B0085
	for <linux-mm@kvack.org>; Sun,  3 Oct 2010 14:11:06 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o93IBL7C031512
	for <linux-mm@kvack.org>; Sun, 3 Oct 2010 14:11:21 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o93IB41I128510
	for <linux-mm@kvack.org>; Sun, 3 Oct 2010 14:11:04 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o93IB39B002097
	for <linux-mm@kvack.org>; Sun, 3 Oct 2010 14:11:04 -0400
Subject: Re: [PATCH 7/9] v3 Define memory_block_size_bytes for
 powerpc/pseries
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20101003180731.GT14064@sgi.com>
References: <4CA62700.7010809@austin.ibm.com>
	 <4CA62A0A.4050406@austin.ibm.com> <20101003175500.GE7896@balbir.in.ibm.com>
	 <20101003180731.GT14064@sgi.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Sun, 03 Oct 2010 11:11:01 -0700
Message-ID: <1286129461.9970.1.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Nathan Fontenot <nfont@austin.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Greg KH <greg@kroah.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

On Sun, 2010-10-03 at 13:07 -0500, Robin Holt wrote:
> On Sun, Oct 03, 2010 at 11:25:00PM +0530, Balbir Singh wrote:
> > * Nathan Fontenot <nfont@austin.ibm.com> [2010-10-01 13:35:54]:
> > 
> > > Define a version of memory_block_size_bytes() for powerpc/pseries such that
> > > a memory block spans an entire lmb.
> > 
> > I hope I am not missing anything obvious, but why not just call it
> > lmb_size, why do we need memblock_size?
> > 
> > Is lmb_size == memblock_size after your changes true for all
> > platforms?
> 
> What is an lmb?  I don't recall anything like lmb being referred to in
> the rest of the kernel.

Heh.  It's the OpenFirmware name for a Logical Memory Block.  Basically
what we use to determine the SECTION_SIZE on powerpc.  Probably not the
best terminology to use elsewhere in the kernel.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
