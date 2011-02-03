Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A86C48D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 11:24:53 -0500 (EST)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1575362Ab1BCQXp (ORCPT <rfc822;linux-mm@kvack.org>);
	Thu, 3 Feb 2011 17:23:45 +0100
Date: Thu, 3 Feb 2011 17:23:45 +0100
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH R3 0/7] xen/balloon: Memory hotplug support for Xen balloon driver
Message-ID: <20110203162345.GC1364@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi,

I am sending next version of memory hotplug
support for Xen balloon driver patch. It applies
to Linus' git tree, v2.6.38-rc3 tag. Most of
suggestions were taken into account. Thanks for
everybody who tested and/or sent suggestions
to my work.

There are a few prerequisite patches which fixes
some problems found during work on memory hotplug
patch or add some futures which are needed by
memory hotplug patch.

Full list of fixes/futures:
  - mm: Add add_registered_memory() to memory hotplug API,
  - xen/balloon: Removal of driver_pages,
  - xen/balloon: HVM mode support,
  - xen/balloon: Migration from mod_timer() to schedule_delayed_work(),
  - xen/balloon: Protect against CPU exhaust by event/x process,
  - xen/balloon: Minor notation fixes,
  - xen/balloon: Memory hotplug support for Xen balloon driver.

Additionally, I suggest to apply patch prepared by Steffano Stabellini
(https://lkml.org/lkml/2011/1/31/232) which fixes memory management
issue in Xen guest. I was not able boot guest machine without
above mentioned patch.

I have received notice that this series of patches broke
machine migration under Xen. I am going to solve that problem ASAP.
I do not have received any notices about other problems till now.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
