Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j2INGaLN003132
	for <linux-mm@kvack.org>; Fri, 18 Mar 2005 18:16:36 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j2INGaXZ093778
	for <linux-mm@kvack.org>; Fri, 18 Mar 2005 18:16:36 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j2INGabG015498
	for <linux-mm@kvack.org>; Fri, 18 Mar 2005 18:16:36 -0500
Subject: Re: [RFC][PATCH 5/6] sparsemem: more separation between NUMA and
	DISCONTIG
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050318150826.4ca3ad14.akpm@osdl.org>
References: <E1DBisA-0000l4-00@kernel.beaverton.ibm.com>
	 <20050318150826.4ca3ad14.akpm@osdl.org>
Content-Type: text/plain
Date: Fri, 18 Mar 2005 15:16:17 -0800
Message-Id: <1111187778.9648.49.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2005-03-18 at 15:08 -0800, Andrew Morton wrote:
> Dave Hansen <haveblue@us.ibm.com> wrote:
> >
> >  There is some confusion with the SPARSEMEM patch between what
> >  is needed for DISCONTIG vs. NUMA.  For instance, the NODE_DATA()
> >  macro needs to be switched on NUMA, but not on FLATMEM.
> > 
> >  This patch is required if the previous patch is applied.
> 
> This patch breaks !CONFIG_NUMA ppc64:
> 
> include/linux/mmzone.h:387:1: warning: "NODE_DATA" redefined
> include/asm/mmzone.h:55:1: warning: this is the location of the previous definition
> 
> I'll hack around it for now.

I'll make sure to have it fixed properly in my copy.

Could I have a copy of your .config?  I'm keeping a growing collection.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
