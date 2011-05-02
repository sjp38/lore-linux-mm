Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4C5506B0012
	for <linux-mm@kvack.org>; Mon,  2 May 2011 17:18:55 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1532337Ab1EBVSG (ORCPT <rfc822;linux-mm@kvack.org>);
	Mon, 2 May 2011 23:18:06 +0200
Date: Mon, 2 May 2011 23:18:06 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH 0/4] mm: Memory hotplug and sparsemem cleanups
Message-ID: <20110502211806.GA4623@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi,

Full list of cleanups:
  - mm: Remove dependency on CONFIG_FLATMEM from online_page(),
  - mm: Enable set_page_section() only if CONFIG_SPARSEMEM
    and !CONFIG_SPARSEMEM_VMEMMAP,
  - mm: pfn_to_section_nr()/section_nr_to_pfn() is valid
    only in CONFIG_SPARSEMEM context,
  - mm: Do not define PFN_SECTION_SHIFT if !CONFIG_SPARSEMEM.

Those patches applies to Linus' git tree, v2.6.39-rc5 tag.
They are required by latest memory hotplug support for Xen balloon
driver patch which will be sent soon.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
