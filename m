Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7E166600068
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 12:26:35 -0500 (EST)
Date: Mon, 4 Jan 2010 11:26:23 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] slab: initialize unused alien cache entry as NULL at
 alloc_alien_cache().
In-Reply-To: <4B31FDCF.9050208@linux.intel.com>
Message-ID: <alpine.DEB.2.00.1001041125090.7191@router.home>
References: <4B30BDA8.1070904@linux.intel.com> <alpine.DEB.2.00.0912220945250.12048@router.home> <4B31BE44.1070308@linux.intel.com> <4B31EC7C.7000302@gmail.com> <20091223102343.GD20539@basil.fritz.box> <4B31FDCF.9050208@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Haicheng Li <haicheng.li@linux.intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Eric Dumazet <eric.dumazet@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 23 Dec 2009, Haicheng Li wrote:

> > It should have been set up by the SRAT parser (modulo regressions)
> >
> > Haicheng, did you verify with printk it's really incorrect at this point?
>
> Yup. See below debug patch & Oops info.
>
> If we can make sure that SRAT parser must be able to detect out all possible
> node (even the node, cpu+mem, is not populated on the motherboard), it would
> be ACPI Parser issue or BIOS issue rather than a slab issue. In such case, I
> think this patch might become a workaround for buggy system board; and we
> might need to look into ACPI SRAT parser code as well:).

Right. Lets fix the SRAT / ACPI issue. Code elsewhere also dimensions
arrays to nr_node_ids.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
