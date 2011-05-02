Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 93D356B0012
	for <linux-mm@kvack.org>; Mon,  2 May 2011 17:46:24 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1581921Ab1EBVqB (ORCPT <rfc822;linux-mm@kvack.org>);
	Mon, 2 May 2011 23:46:01 +0200
Date: Mon, 2 May 2011 23:46:01 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH V2 0/2] mm: Memory hotplug interface changes
Message-ID: <20110502214601.GF4623@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi,

Full list of futures:
  - mm: Add SECTION_ALIGN_UP() and SECTION_ALIGN_DOWN() macro,
  - mm: Extend memory hotplug API to allow memory hotplug in virtual
    machines.

Those patches applies to Linus' git tree, v2.6.39-rc5 tag with a few
prerequisite patches available at https://lkml.org/lkml/2011/5/2/296.

All above mentioned patches are required by latest memory hotplug
support for Xen balloon driver patch which will be sent soon.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
