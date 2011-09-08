Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6AA006B0174
	for <linux-mm@kvack.org>; Wed,  7 Sep 2011 20:27:17 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 799703EE0AE
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 09:27:13 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C0B645DEB5
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 09:27:13 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F39A545DEB2
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 09:27:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E53F81DB8038
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 09:27:12 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AD6881DB8037
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 09:27:12 +0900 (JST)
Date: Thu, 8 Sep 2011 09:26:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Is there any way to stop reclamation of file cache pages ?
Message-Id: <20110908092633.2fcc01d7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CAFPAmTTaq2Lz=eGgfG2-5U0M9aS_aZLNAANAVPZj6TEo9EdjGg@mail.gmail.com>
References: <CAFPAmTTaq2Lz=eGgfG2-5U0M9aS_aZLNAANAVPZj6TEo9EdjGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "kautuk.c @samsung.com" <consul.kautuk@gmail.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-fsdev@vger.rutgers.edu, linux-kernel@vger.kernel.org

On Mon, 5 Sep 2011 14:44:43 +0530
"kautuk.c @samsung.com" <consul.kautuk@gmail.com> wrote:

> Hi,
> 
> I am aware that mlocked pages can be stopped from being reclaimed
> through the PFRA.
> 
> However, is there any method to stop reclamation of the page-cache
> pages pertaining to
> a single file's inode without mlocking ?
> 
> If I want to only use the open, read and write system calls and I want
> to set specific file cache
> pages to "non-reclaimable", how can I do so ?
> 

For this kind of question, you should explain why you can't use mlock.

> Will the POSIX_FADV_WILLNEED option to the fadvise() system call solve
> this problem ?
> 

I think no.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
