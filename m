Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5A9E56B008C
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 08:46:05 -0500 (EST)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1551996Ab0LTNps (ORCPT <rfc822;linux-mm@kvack.org>);
	Mon, 20 Dec 2010 14:45:48 +0100
Date: Mon, 20 Dec 2010 14:45:48 +0100
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH 0/3] Xen memory balloon driver with memory hotplug support
Message-ID: <20101220134548.GA6749@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

This patch is new implementation of Xen memory balloon driver
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
