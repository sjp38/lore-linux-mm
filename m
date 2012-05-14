Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 1F8BF8D0001
	for <linux-mm@kvack.org>; Mon, 14 May 2012 07:58:11 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B55423EE0BB
	for <linux-mm@kvack.org>; Mon, 14 May 2012 20:58:09 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 89EDD2C69C2
	for <linux-mm@kvack.org>; Mon, 14 May 2012 20:58:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 67B43266CE7
	for <linux-mm@kvack.org>; Mon, 14 May 2012 20:58:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 584561DB803E
	for <linux-mm@kvack.org>; Mon, 14 May 2012 20:58:09 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 11A6B1DB802F
	for <linux-mm@kvack.org>; Mon, 14 May 2012 20:58:09 +0900 (JST)
Message-ID: <4FB0F36C.4010906@jp.fujitsu.com>
Date: Mon, 14 May 2012 20:58:36 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [Patch 2/4] x86: use memblock_set_current_limit() to set memblock.current_limit
References: <4FACA79C.9070103@cn.fujitsu.com> <4FB0F174.1000400@jp.fujitsu.com>
In-Reply-To: <4FB0F174.1000400@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

memblock.current_limit is set directly though memblock_set_current_limit()
is prepared. So fix it.

Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
  arch/x86/kernel/setup.c |    4 ++--
  1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-3.4-rc6/arch/x86/kernel/setup.c
===================================================================
--- linux-3.4-rc6.orig/arch/x86/kernel/setup.c	2012-05-15 04:43:11.862313172 +0900
+++ linux-3.4-rc6/arch/x86/kernel/setup.c	2012-05-15 06:44:53.504030089 +0900
@@ -897,7 +897,7 @@ void __init setup_arch(char **cmdline_p)

  	cleanup_highmap();

-	memblock.current_limit = get_max_mapped();
+	memblock_set_current_limit(get_max_mapped());
  	memblock_x86_fill();

  	/*
@@ -933,7 +933,7 @@ void __init setup_arch(char **cmdline_p)
  		max_low_pfn = max_pfn;
  	}
  #endif
-	memblock.current_limit = get_max_mapped();
+	memblock_set_current_limit(get_max_mapped());

  	/*
  	 * NOTE: On x86-32, only from this point on, fixmaps are ready for use.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
