Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 426636B02A6
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 13:18:15 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6GHDdmx027781
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 11:13:39 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id o6GHICZt119500
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 11:18:12 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6GHI9Z5003283
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 11:18:11 -0600
Subject: Re: [PATCH 5/5] v2 Enable multiple sections per directory for ppc
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4C3F5668.2060407@austin.ibm.com>
References: <4C3F53D1.3090001@austin.ibm.com>
	 <4C3F5668.2060407@austin.ibm.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Fri, 16 Jul 2010 10:18:08 -0700
Message-ID: <1279300688.9207.224.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-07-15 at 13:41 -0500, Nathan Fontenot wrote:
>  linux-2.6.orig/arch/powerpc/platforms/pseries/hotplug-memory.c      2010-07-15 09:54:06.000000000 -0500
> +++ linux-2.6/arch/powerpc/platforms/pseries/hotplug-memory.c   2010-07-15 09:56:19.000000000 -0500
> @@ -17,6 +17,54 @@
>  #include <asm/pSeries_reconfig.h>
>  #include <asm/sparsemem.h>
> 
> +static u32 get_memblock_size(void)
> +{
> +       struct device_node *np;
> +       unsigned int memblock_size = 0;
> + 

Please give this sucker some units.  get_memblock_size_bytes()?
get_memblock_size_in_g0ats()?


-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
