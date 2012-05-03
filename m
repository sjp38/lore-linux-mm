Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id E18696B0044
	for <linux-mm@kvack.org>; Thu,  3 May 2012 18:39:30 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 0/2 v2] Flexible proportions for BDIs
Date: Fri,  4 May 2012 00:39:18 +0200
Message-Id: <1336084760-19534-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Wu Fengguang <fengguang.wu@intel.com>, peterz@infradead.org


  Hello,

  this is the second iteration of my patches for flexible proportions. Since
previous submission, I've converted BDI proportion calculations to use flexible
proportions so now we can test proportions in kernel. Fengguang, can you give
them a run in your JBOD setup? You might try to tweak VM_COMPLETIONS_PERIOD_LEN
if things are fluctuating too much... I'm not yet completely decided how to set
that constant. Thanks!

								Honza

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
