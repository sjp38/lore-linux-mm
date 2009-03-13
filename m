Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 855A26B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 13:34:08 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 0/2] Make the Unevictable LRU available on NOMMU
Date: Fri, 13 Mar 2009 17:33:43 +0000
Message-ID: <20090313173343.10169.58053.stgit@warthog.procyon.org.uk>
In-Reply-To: <20090312100049.43A3.A69D9226@jp.fujitsu.com>
References: <20090312100049.43A3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com
Cc: dhowells@redhat.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, peterz@infradead.org, nrik.Berkhan@ge.com, uclinux-dev@uclinux.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, riel@surriel.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>


The first patch causes the mlock() bits added by CONFIG_UNEVICTABLE_LRU to be
unavailable in NOMMU mode.

The second patch makes CONFIG_UNEVICTABLE_LRU available in NOMMU mode.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
