Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 5E0256B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 03:18:40 -0500 (EST)
Date: Mon, 7 Nov 2011 09:18:24 +0100
From: Witold Baryluk <baryluk@smp.if.uj.edu.pl>
Subject: Possible usage of uninitalized task_ratelimit variable in
 mm/page-writeback.c
Message-ID: <20111107081824.GA18221@smp.if.uj.edu.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org

Hi,

I found a minor issue when compiling kernel today


  CC      mm/page-writeback.o
mm/page-writeback.c: In function a??balance_dirty_pages_ratelimited_nra??:
include/trace/events/writeback.h:281:1: warning: a??task_ratelimita?? may be used uninitialized in this function [-Wuninitialized]
mm/page-writeback.c:1018:16: note: a??task_ratelimita?? was declared here

Indeed in balance_dirty_pages a task_ratelimit may be not initialized
(initialization skiped by goto pause;), and then used when calling
tracing hook.

Regards,
Witek


-- 
Witold Baryluk
JID: witold.baryluk // jabster.pl

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
