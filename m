Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D639F6B004F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 19:49:28 -0400 (EDT)
From: Vladislav Buzov <vbuzov@embeddedalley.com>
Subject: [PATCH 0/2] Memory usage limit notification feature (v3)
Date: Mon, 13 Jul 2009 17:16:19 -0700
Message-Id: <1247530581-31416-1-git-send-email-vbuzov@embeddedalley.com>
In-Reply-To: <1246998310-16764-1-git-send-email-vbuzov@embeddedalley.com>
References: <1246998310-16764-1-git-send-email-vbuzov@embeddedalley.com>
Sender: owner-linux-mm@kvack.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: Linux Containers Mailing List <containers@lists.linux-foundation.org>, Linux memory management list <linux-mm@kvack.org>, Dan Malek <dan@embeddedalley.com>, Andrew Morton <akpm@linux-foundation.org>, Paul Menage <menage@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>


The following sequence of patches introduce memory usage limit notification
capability to the Memory Controller cgroup.

This is v3 of the implementation. The major difference between previous
version is it is based on the the Resource Counter extension to notify the
Resource Controller when the resource usage achieves or exceeds a configurable
threshold.

TODOs:

1. Another, more generic notification mechanism supporting different  events
   is preferred to use, rather than creating a dedicated file in the Memory
   Controller cgroup.


Thanks,
Vlad.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
