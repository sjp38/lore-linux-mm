Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 399796B00A0
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 23:13:03 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n693QQbg017606
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 9 Jul 2009 12:26:26 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 247A245DE4E
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 12:26:26 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E987345DE4D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 12:26:25 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D17941DB8040
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 12:26:25 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 855811DB803C
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 12:26:25 +0900 (JST)
Date: Thu, 9 Jul 2009 12:24:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/2] ZERO PAGE again v3.
Message-Id: <20090709122428.8c2d4232.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, npiggin@suse.de, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, avi@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, torvalds@linux-foundation.org, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

After v2 discussion, I felt that "Go" sign can be given if implemetaion is neat
and tiny and overhead seems very small. Here is v3.

In this version,

 - use pte_special() in vm_normal_page()
   All ZERO_PAGE check will go down to vm_normal_page() and check is done here.
   Some new flags in follow_page() and get_user_pages().

 - per arch use-zero-page config is added.
   IIUC, archs which have _PAGE_SPECIAL is only x86, powerpc, s390.
   Because this patch make use of pte_special() check, config to use zero page
   is added and you can turn it off if necessary.
   I this patch, only x86 is turned on which I can test.

Any comments are welcome. 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
