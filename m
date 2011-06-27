Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 301216B018F
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 01:39:11 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5F3C83EE0C5
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 14:39:04 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 460FA45DE79
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 14:39:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E8E645DE7D
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 14:39:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E772A1DB803A
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 14:39:03 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B14AC1DB8041
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 14:39:03 +0900 (JST)
Message-ID: <4E081764.7040709@jp.fujitsu.com>
Date: Mon, 27 Jun 2011 14:38:44 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] fadvise: move active pages to inactive list with
 POSIX_FADV_DONTNEED
References: <1308779480-4950-1-git-send-email-andrea@betterlinux.com> <4E03200D.60704@draigBrady.com>
In-Reply-To: <4E03200D.60704@draigBrady.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: P@draigBrady.com
Cc: andrea@betterlinux.com, akpm@linux-foundation.org, minchan.kim@gmail.com, riel@redhat.com, peterz@infradead.org, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, aarcange@redhat.com, hughd@google.com, jamesjer@betterlinux.com, marcus@bluehost.com, matt@bluehost.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> Hmm, What if you do want to evict it from the cache for testing purposes?
> Perhaps this functionality should be associated with POSIX_FADV_NOREUSE?
> dd has been recently modified to support invalidating the cache for a file,
> and it uses POSIX_FADV_DONTNEED for that.
> http://git.sv.gnu.org/gitweb/?p=coreutils.git;a=commitdiff;h=5f311553

This change don't break dd. dd don't have a special privilege of file cache
dropping if it's also used by other processes.

if you want to drop a cache forcely (maybe for testing), you need to use
/proc/sys/vm/drop_caches. It's ok to ignore other processes activity because
it's privilege operation.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
