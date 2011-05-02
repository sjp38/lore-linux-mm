Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C31196B0012
	for <linux-mm@kvack.org>; Mon,  2 May 2011 18:19:31 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1581921Ab1EBWS5 (ORCPT <rfc822;linux-mm@kvack.org>);
	Tue, 3 May 2011 00:18:57 +0200
Date: Tue, 3 May 2011 00:18:57 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: Re: [PATCH 1/4] mm: Remove dependency on CONFIG_FLATMEM from online_page()
Message-ID: <20110502221857.GJ4623@router-fw-old.local.net-space.pl>
References: <20110502211915.GB4623@router-fw-old.local.net-space.pl> <1304371504.30823.45.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1304371504.30823.45.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Daniel Kiper <dkiper@net-space.pl>, ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, May 02, 2011 at 02:25:04PM -0700, Dave Hansen wrote:
> On Mon, 2011-05-02 at 23:19 +0200, Daniel Kiper wrote:
> > Memory hotplug code strictly depends on CONFIG_SPARSEMEM.
> > It means that code depending on CONFIG_FLATMEM in online_page()
> > is never compiled. Remove it because it is not needed anymore.
>
> It's subtle, but I don't think that's true.  We had another hotplug mode
> for x86_64 before folks were comfortable turning SPARSEMEM on for the
> whole architecture.  It was quite possible to have memory hotplug
> without sparsemem in that case.  I think Keith Mannthey did some of that
> code if I remember right.
>
> But, I'm not sure how much of that stayed in distros versus made it
> upstream.  In any case, you might want to chase down the
> X86_64_ACPI_NUMA bit to make sure it can't be used with FLATMEM ever.
>
> config MEMORY_HOTPLUG
>         bool "Allow for memory hot-add"
>         depends on SPARSEMEM || X86_64_ACPI_NUMA
>         depends on HOTPLUG && ARCH_ENABLE_MEMORY_HOTPLUG
>         depends on (IA64 || X86 || PPC_BOOK3S_64 || SUPERH || S390)

IIRC some time ago it was possible to enable memory hotplug with
CONFIG_FLATMEM. That is why I looked for any dependencies of memory
hoplug code on CONFIG_FLATMEM in current Linux Kernel source. I could
not find anything and that is why I published this patch. However,
maybe I missed something.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
