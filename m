Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id iAHHCMDi005680
	for <linux-mm@kvack.org>; Wed, 17 Nov 2004 12:12:22 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iAHHCJOd267098
	for <linux-mm@kvack.org>; Wed, 17 Nov 2004 12:12:22 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iAHHCIRR024749
	for <linux-mm@kvack.org>; Wed, 17 Nov 2004 12:12:18 -0500
Subject: Re: [Lhms-devel] [RFC] fix for hot-add enabled SRAT/BIOS and numa
	KVA areas
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1100659057.26335.125.camel@knk>
References: <1100659057.26335.125.camel@knk>
Content-Type: text/plain
Message-Id: <1100711519.5838.2.camel@localhost>
Mime-Version: 1.0
Date: Wed, 17 Nov 2004 09:11:59 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: keith <kmannth@us.ibm.com>
Cc: external hotplug mem list <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>, Chris McDermott <lcm@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2004-11-16 at 18:37, keith wrote:
>   The numa KVA code used the node_start and node_end values (obtained
> from the above memory ranges) to make it's lowmem reservations.  The
> problem is that the lowmem area reserved is quite large.  It reserves
> the entire a lmem_map large enough for 0x1000000 address space.  I don't
> feel this is a great use of lowmem on my system :)

It does seem silly to waste all of that lowmem for memory that *might*
be there, but what do you plan to do for contiguous address space (for
mem_map) once the memory addition occurs?  We've always talked about
having to preallocate mem_map space on 32-bit platforms and by your
patch it appears that this isn't what you want to do.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
