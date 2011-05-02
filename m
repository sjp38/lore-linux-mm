Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D080E6B0012
	for <linux-mm@kvack.org>; Mon,  2 May 2011 18:48:54 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p42MTJ80030063
	for <linux-mm@kvack.org>; Mon, 2 May 2011 18:29:19 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p42MmrL6107846
	for <linux-mm@kvack.org>; Mon, 2 May 2011 18:48:53 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p42ImeCv000780
	for <linux-mm@kvack.org>; Mon, 2 May 2011 15:48:41 -0300
Subject: Re: [PATCH 1/4] mm: Remove dependency on CONFIG_FLATMEM from
 online_page()
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110502221857.GJ4623@router-fw-old.local.net-space.pl>
References: <20110502211915.GB4623@router-fw-old.local.net-space.pl>
	 <1304371504.30823.45.camel@nimitz>
	 <20110502221857.GJ4623@router-fw-old.local.net-space.pl>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Mon, 02 May 2011 15:48:48 -0700
Message-ID: <1304376528.30823.47.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 2011-05-03 at 00:18 +0200, Daniel Kiper wrote:
> 
> > config MEMORY_HOTPLUG
> >         bool "Allow for memory hot-add"
> >         depends on SPARSEMEM || X86_64_ACPI_NUMA
> >         depends on HOTPLUG && ARCH_ENABLE_MEMORY_HOTPLUG
> >         depends on (IA64 || X86 || PPC_BOOK3S_64 || SUPERH || S390)
> 
> IIRC some time ago it was possible to enable memory hotplug with
> CONFIG_FLATMEM. That is why I looked for any dependencies of memory
> hoplug code on CONFIG_FLATMEM in current Linux Kernel source. I could
> not find anything and that is why I published this patch. However,
> maybe I missed something.

I can't find any immediately apparent case, either.  Guess that's what
LKML is for. :)

Acked-by: Dave Hansen <dave@linux.vnet.ibm.com>

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
