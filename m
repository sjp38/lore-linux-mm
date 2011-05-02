Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 28A376B0012
	for <linux-mm@kvack.org>; Mon,  2 May 2011 17:25:11 -0400 (EDT)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p42LEF1s009152
	for <linux-mm@kvack.org>; Mon, 2 May 2011 17:14:15 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p42LP9mR815132
	for <linux-mm@kvack.org>; Mon, 2 May 2011 17:25:09 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p42LP7MN019680
	for <linux-mm@kvack.org>; Mon, 2 May 2011 17:25:08 -0400
Subject: Re: [PATCH 1/4] mm: Remove dependency on CONFIG_FLATMEM from
 online_page()
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110502211915.GB4623@router-fw-old.local.net-space.pl>
References: <20110502211915.GB4623@router-fw-old.local.net-space.pl>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Mon, 02 May 2011 14:25:04 -0700
Message-ID: <1304371504.30823.45.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2011-05-02 at 23:19 +0200, Daniel Kiper wrote:
> Memory hotplug code strictly depends on CONFIG_SPARSEMEM.
> It means that code depending on CONFIG_FLATMEM in online_page()
> is never compiled. Remove it because it is not needed anymore.

It's subtle, but I don't think that's true.  We had another hotplug mode
for x86_64 before folks were comfortable turning SPARSEMEM on for the
whole architecture.  It was quite possible to have memory hotplug
without sparsemem in that case.  I think Keith Mannthey did some of that
code if I remember right.

But, I'm not sure how much of that stayed in distros versus made it
upstream.  In any case, you might want to chase down the
X86_64_ACPI_NUMA bit to make sure it can't be used with FLATMEM ever.

config MEMORY_HOTPLUG
        bool "Allow for memory hot-add"
        depends on SPARSEMEM || X86_64_ACPI_NUMA
        depends on HOTPLUG && ARCH_ENABLE_MEMORY_HOTPLUG
        depends on (IA64 || X86 || PPC_BOOK3S_64 || SUPERH || S390)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
