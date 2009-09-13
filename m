Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 508876B004F
	for <linux-mm@kvack.org>; Sun, 13 Sep 2009 15:43:26 -0400 (EDT)
Date: Sun, 13 Sep 2009 20:42:38 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Isolated(anon) and Isolated(file)
Message-ID: <Pine.LNX.4.64.0909132011550.28745@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi KOSAKI-san,

May I question the addition of Isolated(anon) and Isolated(file)
lines to /proc/meminfo?  I get irritated by all such "0 kB" lines!

I see their appropriateness and usefulness in the Alt-Sysrq-M-style
info which accompanies an OOM; and I see that those statistics help
you to identify and fix bugs of having too many pages isolated.

But IMHO they're too transient to be appropriate in /proc/meminfo:
by the time the "cat /proc/meminfo" is done, the situation is very
different (or should be once the bugs are fixed).

Almost all its numbers are transient, of course, but these seem
so much so that I think /proc/meminfo is better off without them
(compressing more info into fewer lines).

Perhaps I'm in the minority: if others care, what do they think?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
