Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 753156B02A4
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 21:49:41 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6T1nbM9023858
	for <linux-mm@kvack.org> (envelope-from iram.shahzad@jp.fujitsu.com);
	Thu, 29 Jul 2010 10:49:37 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A0EB245DE52
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 10:49:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DA6C45DE50
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 10:49:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 608A71DB8052
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 10:49:37 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E240F1DB804F
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 10:49:33 +0900 (JST)
Message-ID: <D25878F935704D9281E62E0393CAD951@rainbow>
From: "Iram Shahzad" <iram.shahzad@jp.fujitsu.com>
Subject: compaction: why depends on HUGETLB_PAGE
Date: Thu, 29 Jul 2010 10:53:12 +0900
MIME-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-2022-jp";
	reply-type=original
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

Hi

I have found that memory compaction (CONFIG_COMPACTION)
is mainlined while looking at 2.6.35-rc5 source code.
I have a question regarding its dependency on HUGETLB_PAGE.

While trying to use CONFIG_COMPACTION on ARM architecture,
I found that I cannot enable CONFIG_COMPACTION because
it depends on CONFIG_HUGETLB_PAGE which is not available
on ARM.

I disabled the dependency and was able to build it.
And it looks like working!

My question is: why does it depend on CONFIG_HUGETLB_PAGE?
Is it wrong to use it on ARM by disabling CONFIG_HUGETLB_PAGE?

Iram


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
