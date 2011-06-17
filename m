Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 817BB6B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 20:53:49 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 111BE3EE0C1
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 09:53:43 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E2E0245DE4D
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 09:53:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CC6D845DE6A
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 09:53:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C0BBC1DB803C
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 09:53:42 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E9A51DB802C
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 09:53:42 +0900 (JST)
Date: Fri, 17 Jun 2011 09:46:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH][-rc3] Define a consolidated definition of
 node_start/end_pfn for build error in page_cgroup.c (Was Re: mmotm
 2011-06-15-16-56 uploaded (mm/page_cgroup.c)
Message-Id: <20110617094628.aecf5ee1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110616103559.GA5244@suse.de>
References: <201106160034.p5G0Y4dr028904@imap1.linux-foundation.org>
	<20110615214917.a7dce8e6.randy.dunlap@oracle.com>
	<20110616172819.1e2d325c.kamezawa.hiroyu@jp.fujitsu.com>
	<20110616103559.GA5244@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, dave@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, mingo@elte.hu

On Thu, 16 Jun 2011 11:35:59 +0100
Mel Gorman <mgorman@suse.de> wrote:

> A caller that does node_end_pfn(nid++) will get a nasty surprise
> due to side-effects. I know architectures currently get this wrong
> including x86_64 but we might as well fix it up now. The definition
> in arch/x86/include/asm/mmzone_32.h is immune to side-effects and
> might be a better choice despite the use of a temporary variable.
> 

Ok, here is a fixed one. Thank you for comments/review.
==
