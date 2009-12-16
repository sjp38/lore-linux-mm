Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A6C8C6B0044
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 22:03:24 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBG33LI2024091
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 16 Dec 2009 12:03:21 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 89FEC45DE52
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:03:21 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C76845DE4F
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:03:21 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A0AB1DB803E
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:03:21 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id DA4A11DB8038
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:03:20 +0900 (JST)
Date: Wed, 16 Dec 2009 12:00:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [mm][RFC][PATCH 0/11] mm accessor updates.
Message-Id: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, andi@firstfloor.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

This is from Christoph Lameter's mm_accessor patch posted 5/Nov.

Replacing all access to mm->mmap_sem with mm-accessor functions as
 mm_read_lock,
 mm_write_lock,
 etc...

This kind of function allows us to improve page fault performance etc..
For example, skil down_read(mmap_sem) in some situation.
(as: http://marc.info/?l=linux-mm&m=125809791306459&w=2)

Because I like this idea, I updated his patch. But the size of patch is
very big and mmap_sem is used in many place, some senario for merging
will be required. Spliting into small pieace and go ahead in step by step.

My plan is...
  1. leave  mm->mmap_sem as it is for a while.
  2. replace all mmap_sem access under /kernel /mm /fs etc..
  3. replace all mmap_sem callers under /driver
  4. And finally, post per-arch patches.

Now this set is organized as
 [1/11] mm_accessor definition
 [2/11] a patch for kernel, mm
 [3/11] a patch for fs (procfs and codes around get_user_page())
 [4/11] a patch for kvm
 [5/11] a patch for tomoyo
 [6/11] a patch for driver/gpu
 [7/11] a patch for infiniband
 [8/11] a patch for driver/media/video
 [9/11] a patch for sgi gru
 [10/11] a patch for misc drivers
 [11/11] a patch for x86.

I think, once I push [1/11] (and 2/11]), I can update other calls in each tree.
And finally successfully rename mm->mmap_sem to some other name.

Any comment is welcome.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
