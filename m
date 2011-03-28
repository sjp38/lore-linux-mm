Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 60EBC8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 05:31:52 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1577721Ab1C1Jb2 (ORCPT <rfc822;linux-mm@kvack.org>);
	Mon, 28 Mar 2011 11:31:28 +0200
Date: Mon, 28 Mar 2011 11:31:28 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH 0/4] xen/balloon: Cleanups and fixes for 2.6.40
Message-ID: <20110328093128.GE13826@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi,

Full list of cleanups/fixes:
  - xen/balloon: Use PageHighMem() for high memory page detection,
  - xen/balloon: Simplify HVM integration,
  - xen/balloon: Clarify credit calculation,
  - xen/balloon: Move dec_totalhigh_pages() from __balloon_append() to balloon_append().

Those patches applies to latest Linus' git tree
(git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git).
They are required by latest memory hotplug support for Xen balloon
driver patch which will be sent soon.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
