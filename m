Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8F8CB6B008C
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 04:00:25 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBK90MoU021011
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 20 Dec 2010 18:00:22 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2838645DE5D
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 18:00:22 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E87E45DE5A
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 18:00:22 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0114E1DB803B
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 18:00:22 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BEB57E08002
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 18:00:21 +0900 (JST)
Date: Mon, 20 Dec 2010 17:54:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 5/5] truncate: Remove unnecessary page release
Message-Id: <20101220175429.4c469c3d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTikn-ZyBKwVaDwuQ=QSvB=wLwY40u8FHGyWccStm@mail.gmail.com>
References: <cover.1292604745.git.minchan.kim@gmail.com>
	<02ab98b3a1450f7a1c31edc48ccc57e887cee900.1292604746.git.minchan.kim@gmail.com>
	<20101220112227.E566.A69D9226@jp.fujitsu.com>
	<20101220112733.064f2fe3.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTi=UfmZNfKWCisrs6ezzoWqpcwUOT5bs8LGwN7Rv@mail.gmail.com>
	<20101220133526.e075feb8.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikn-ZyBKwVaDwuQ=QSvB=wLwY40u8FHGyWccStm@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Al Viro <viro@zeniv.linux.org.uk>
List-ID: <linux-mm.kvack.org>

On Mon, 20 Dec 2010 17:09:11 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Because the page is locked and is detached from page cache, I guess
> it's no problem.
> Anyway, I think It's off-topic.
> 

yes.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
