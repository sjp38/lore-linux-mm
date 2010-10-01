Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7EC456B0047
	for <linux-mm@kvack.org>; Fri,  1 Oct 2010 15:20:27 -0400 (EDT)
Date: Fri, 1 Oct 2010 14:20:25 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 4/9] v3 Allow memory blocks to span multiple memory
 sections
Message-ID: <20101001192025.GQ14064@sgi.com>
References: <4CA62700.7010809@austin.ibm.com>
 <4CA62917.80008@austin.ibm.com>
 <4CA62FE2.2000003@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4CA62FE2.2000003@austin.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Robin Holt <holt@sgi.com>, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, Oct 01, 2010 at 02:00:50PM -0500, Nathan Fontenot wrote:
> Update the memory sysfs code such that each sysfs memory directory is now
> considered a memory block that can span multiple memory sections per
> memory block.  The default size of each memory block is SECTION_SIZE_BITS
> to maintain the current behavior of having a single memory section per
> memory block (i.e. one sysfs directory per memory section).
> 
> For architectures that want to have memory blocks span multiple
> memory sections they need only define their own memory_block_size_bytes()
> routine.
> 
> Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>

Reviewed-by: Robin Holt <holt@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
