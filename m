Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 247736B01EE
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 03:41:26 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o317fMJv011726
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 1 Apr 2010 16:41:22 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6877C45DE50
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 16:41:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4842A45DE4E
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 16:41:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 293E5E38001
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 16:41:22 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C89B6EF8027
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 16:41:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [LSF/MM TOPIC][ATTEND] How to fix direct-io vs fork issue
Message-Id: <20100401154419.BE4C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  1 Apr 2010 16:41:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, lsf10-pc@lists.linuxfoundation.org
Cc: kosaki.motohiro@jp.fujitsu.com, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi

I would like to ask about one difficult problem about people.
currently, direct-io implementation has big sick about VM interaction.
it assume get_user_pages() can pin the target pages in page's mm. but 
it doesn't. fork and cow might replace the relationship between task's mm
and pages. therefore cuncurrent directio and fork can corrupt the process's
data.

There was two proposal in past day. 1) introduce new page flags 2)
introduce new lock. unfortunately both proposal got strong complaint
from other developers. then, we still have this issue.

I don't have clever idea. I hope discuss how to fix or give it up.


thanks to linus. his recent read_pagemap discussion restre my memory that
I need post this mail.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
