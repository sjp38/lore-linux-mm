Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id DE0436B0078
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 10:04:06 -0500 (EST)
Received: by fxm22 with SMTP id 22so403311fxm.6
        for <linux-mm@kvack.org>; Tue, 02 Mar 2010 07:04:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100302125306.GD19208@basil.fritz.box>
References: <alpine.DEB.2.00.1002240949140.26771@router.home>
	 <alpine.DEB.2.00.1002242357450.26099@chino.kir.corp.google.com>
	 <alpine.DEB.2.00.1002251228140.18861@router.home>
	 <20100226114136.GA16335@basil.fritz.box>
	 <alpine.DEB.2.00.1002260904311.6641@router.home>
	 <20100226155755.GE16335@basil.fritz.box>
	 <alpine.DEB.2.00.1002261123520.7719@router.home>
	 <alpine.DEB.2.00.1002261555030.32111@chino.kir.corp.google.com>
	 <alpine.DEB.2.00.1003010224170.26824@chino.kir.corp.google.com>
	 <20100302125306.GD19208@basil.fritz.box>
Date: Tue, 2 Mar 2010 17:04:00 +0200
Message-ID: <84144f021003020704s3abafc24t9b8ab34234094b79@mail.gmail.com>
Subject: Re: [patch] slab: add memory hotplug support
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi Andi,

On Tue, Mar 2, 2010 at 2:53 PM, Andi Kleen <andi@firstfloor.org> wrote:
> On Mon, Mar 01, 2010 at 02:24:43AM -0800, David Rientjes wrote:
>> Slab lacks any memory hotplug support for nodes that are hotplugged
>> without cpus being hotplugged. =A0This is possible at least on x86
>> CONFIG_MEMORY_HOTPLUG_SPARSE kernels where SRAT entries are marked
>> ACPI_SRAT_MEM_HOT_PLUGGABLE and the regions of RAM represent a seperate
>> node. =A0It can also be done manually by writing the start address to
>> /sys/devices/system/memory/probe for kernels that have
>> CONFIG_ARCH_MEMORY_PROBE set, which is how this patch was tested, and
>> then onlining the new memory region.
>
> The patch looks far more complicated than my simple fix.

I wouldn't exactly call the fallback_alloc() games "simple".

> Is more complicated now better?

Heh, heh. You can't post the oops, you don't want to rework your
patches as per review comments, and now you complain about David's
patch without one bit of technical content. I'm sorry but I must
conclude that someone is playing a prank on me because there's no way
a seasoned kernel hacker such as yourself could possibly think that
this is the way to get patches merged.

But anyway, if you have real technical concerns over the patch, please
make them known; otherwise I'd much appreciate a Tested-by tag from
you for David's patch.

Thanks,

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
