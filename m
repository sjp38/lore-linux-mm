Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BE6116B0078
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 07:53:17 -0500 (EST)
Date: Tue, 2 Mar 2010 13:53:06 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch] slab: add memory hotplug support
Message-ID: <20100302125306.GD19208@basil.fritz.box>
References: <alpine.DEB.2.00.1002240949140.26771@router.home> <4B862623.5090608@cs.helsinki.fi> <alpine.DEB.2.00.1002242357450.26099@chino.kir.corp.google.com> <alpine.DEB.2.00.1002251228140.18861@router.home> <20100226114136.GA16335@basil.fritz.box> <alpine.DEB.2.00.1002260904311.6641@router.home> <20100226155755.GE16335@basil.fritz.box> <alpine.DEB.2.00.1002261123520.7719@router.home> <alpine.DEB.2.00.1002261555030.32111@chino.kir.corp.google.com> <alpine.DEB.2.00.1003010224170.26824@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003010224170.26824@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 01, 2010 at 02:24:43AM -0800, David Rientjes wrote:
> Slab lacks any memory hotplug support for nodes that are hotplugged
> without cpus being hotplugged.  This is possible at least on x86
> CONFIG_MEMORY_HOTPLUG_SPARSE kernels where SRAT entries are marked
> ACPI_SRAT_MEM_HOT_PLUGGABLE and the regions of RAM represent a seperate
> node.  It can also be done manually by writing the start address to
> /sys/devices/system/memory/probe for kernels that have
> CONFIG_ARCH_MEMORY_PROBE set, which is how this patch was tested, and
> then onlining the new memory region.

The patch looks far more complicated than my simple fix.

Is more complicated now better?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
