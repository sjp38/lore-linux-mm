Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0263D6B024D
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 15:23:16 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6KJF46X032378
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 13:15:04 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6KJNCFs075614
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 13:23:12 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6KJN5Dn012564
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 13:23:06 -0600
Subject: Re: [PATCH 8/8] v3 Update memory-hotplug documentation
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4C451F3F.8000207@austin.ibm.com>
References: <4C451BF5.50304@austin.ibm.com>
	 <4C451F3F.8000207@austin.ibm.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Tue, 20 Jul 2010 12:23:04 -0700
Message-ID: <1279653784.9785.6.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, greg@kroah.com
List-ID: <linux-mm.kvack.org>

On Mon, 2010-07-19 at 22:59 -0500, Nathan Fontenot wrote:
> 
> 
> -Now, XXX is defined as start_address_of_section / section_size.
> +Now, XXX is defined as (start_address_of_section / section_size) of
> the first
> +section conatined in the memory block.
> 
>  For example, assume 1GiB section size. A device for a memory starting
> at
>  0x100000000 is /sys/device/system/memory/memory4
>  (0x100000000 / 1Gib = 4)
>  This device covers address range [0x100000000 ... 0x140000000)
> 
> -Under each section, you can see 4 files.
> +Under each section, you can see 5 files.
> 
> -/sys/devices/system/memory/memoryXXX/phys_index
> +/sys/devices/system/memory/memoryXXX/start_phys_index
> +/sys/devices/system/memory/memoryXXX/end_phys_index 

Just wanted to make sure you didn't forget to update this after KAME's
comments on the first couple of patches.


-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
