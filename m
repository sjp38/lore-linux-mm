Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m948EpgC017010
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sat, 4 Oct 2008 17:14:51 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 81BCC53C124
	for <linux-mm@kvack.org>; Sat,  4 Oct 2008 17:14:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 58B7724005C
	for <linux-mm@kvack.org>; Sat,  4 Oct 2008 17:14:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F1541DB803C
	for <linux-mm@kvack.org>; Sat,  4 Oct 2008 17:14:51 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E40AF1DB8037
	for <linux-mm@kvack.org>; Sat,  4 Oct 2008 17:14:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] Report the pagesize backing a VMA in /proc/pid/maps
In-Reply-To: <1223052415-18956-3-git-send-email-mel@csn.ul.ie>
References: <1223052415-18956-1-git-send-email-mel@csn.ul.ie> <1223052415-18956-3-git-send-email-mel@csn.ul.ie>
Message-Id: <20081004171256.CE3C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sat,  4 Oct 2008 17:14:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, dave@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> This patch adds a new field for hugepage-backed memory regions to show the
> pagesize in /proc/pid/maps.  While the information is available in smaps,
> maps is more human-readable and does not incur the cost of calculating Pss. An
> example of a /proc/self/maps output for an application using hugepages with
> this patch applied is;
> 
> 08048000-0804c000 r-xp 00000000 03:01 49135      /bin/cat
> 0804c000-0804d000 rw-p 00003000 03:01 49135      /bin/cat
> 08400000-08800000 rw-p 00000000 00:10 4055       /mnt/libhugetlbfs.tmp.QzPPTJ (deleted) (hpagesize=4096kB)
> b7daa000-b7dab000 rw-p b7daa000 00:00 0
> b7dab000-b7ed2000 r-xp 00000000 03:01 116846     /lib/tls/i686/cmov/libc-2.3.6.so
> b7ed2000-b7ed7000 r--p 00127000 03:01 116846     /lib/tls/i686/cmov/libc-2.3.6.so
> b7ed7000-b7ed9000 rw-p 0012c000 03:01 116846     /lib/tls/i686/cmov/libc-2.3.6.so
> b7ed9000-b7edd000 rw-p b7ed9000 00:00 0
> b7ee1000-b7ee8000 r-xp 00000000 03:01 49262      /root/libhugetlbfs-git/obj32/libhugetlbfs.so
> b7ee8000-b7ee9000 rw-p 00006000 03:01 49262      /root/libhugetlbfs-git/obj32/libhugetlbfs.so
> b7ee9000-b7eed000 rw-p b7ee9000 00:00 0
> b7eed000-b7f02000 r-xp 00000000 03:01 119345     /lib/ld-2.3.6.so
> b7f02000-b7f04000 rw-p 00014000 03:01 119345     /lib/ld-2.3.6.so
> bf8ef000-bf903000 rwxp bffeb000 00:00 0          [stack]
> bf903000-bf904000 rw-p bffff000 00:00 0
> ffffe000-fffff000 r-xp 00000000 00:00 0          [vdso]
> 
> To be predictable for parsers, the patch adds the notion of reporting on VMA
> attributes by appending one or more fields that look like "(attribute)". This
> already happens when a file is deleted and the user sees (deleted) after the
> filename. The expectation is that existing parsers will not break as those
> that read the filename should be reading forward after the inode number
> and stopping when it sees something that is not part of the filename.
> Parsers that assume everything after / is a filename will get confused by
> (hpagesize=XkB) but are already broken due to (deleted).
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

This patch is nicer and cleaner than my version.
Thanks! mel.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
