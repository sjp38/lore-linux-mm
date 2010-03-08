Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A9D6C6B00AB
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 09:00:03 -0500 (EST)
From: David Howells <dhowells@redhat.com>
Subject: sync_mm_rss() issues
Date: Mon, 08 Mar 2010 13:59:56 +0000
Message-ID: <30859.1268056796@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kamezawa.hiroyu@jp.fujitsu.com, torvalds@osdl.org
Cc: dhowells@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


There are a couple of issues with sync_mm_rss(), as added by patch:

	commit 34e55232e59f7b19050267a05ff1226e5cd122a5
	Author: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
	Date:   Fri Mar 5 13:41:40 2010 -0800
	Subject: mm: avoid false sharing of mm_counter

 (1) You haven't implemented it for NOMMU mode.  What's the right way to do
     this?  Just give an empty function?

 (2) linux/mm.h should carry the empty function as an inline when
     CONFIG_SPLIT_RSS_COUNTING=n, rather than it being defined as an empty
     function in mm/memory.c.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
