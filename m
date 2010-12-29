Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id F073F6B0089
	for <linux-mm@kvack.org>; Wed, 29 Dec 2010 12:01:58 -0500 (EST)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1564463Ab0L2RA7 (ORCPT <rfc822;linux-mm@kvack.org>);
	Wed, 29 Dec 2010 18:00:59 +0100
Date: Wed, 29 Dec 2010 18:00:59 +0100
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH R2 0/7] Xen memory balloon driver with memory hotplug support
Message-ID: <20101229170059.GE2743@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

This patch (r2) is new implementation of Xen memory balloon driver
with memory hotplug support. Additionally, it contains some
balloon driver extra features and fixes. It cleanly applies
to Linux kernel Ver. 2.6.36.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
