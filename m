Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 047589000BD
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 10:56:16 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5KEYZV3004906
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 10:34:35 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5KEu3Vf507936
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 10:56:03 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5K8tMNB009929
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 02:55:22 -0600
Subject: Re: [PATCH] REPOST: Memory tracking for physical machine migration
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110610231850.6327.24452.sendpatchset@localhost.localdomain>
References: <20110610231850.6327.24452.sendpatchset@localhost.localdomain>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 20 Jun 2011 07:55:41 -0700
Message-ID: <1308581741.11430.222.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jim Paradis <james.paradis@stratus.com>
Cc: linux-mm@kvack.org

On Fri, 2011-06-10 at 19:19 -0400, Jim Paradis wrote:
> diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
> index 3e608ed..a416317 100644
> --- a/arch/x86/mm/Makefile
> +++ b/arch/x86/mm/Makefile
> @@ -30,3 +30,5 @@ obj-$(CONFIG_NUMA_EMU)                += numa_emulation.o
>  obj-$(CONFIG_HAVE_MEMBLOCK)            += memblock.o
> 
>  obj-$(CONFIG_MEMTEST)          += memtest.o
> +
> +obj-$(CONFIG_TRACK_DIRTY_PAGES)        += track.o 

FWIW, this is still having formatting problems.

You also forgot to include track.c, again.  Isn't that where the real
meat of this patch lies?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
