Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 13D616B0071
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 19:53:06 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAO0r4dN025246
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 24 Nov 2010 09:53:05 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 97B8545DE5A
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:53:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 726AD45DD77
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:53:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 56BEF1DB803C
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:53:04 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F2D91DB803B
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:53:04 +0900 (JST)
Date: Wed, 24 Nov 2010 09:47:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Question about cgroup hierarchy and reducing memory limit
Message-Id: <20101124094736.3c4ba760.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTingzd3Pqrip1izfkLm+HCE9jRQL777nu9s3RnLv@mail.gmail.com>
References: <AANLkTingzd3Pqrip1izfkLm+HCE9jRQL777nu9s3RnLv@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Evgeniy Ivanov <lolkaantimat@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 Nov 2010 19:59:41 +0300
Evgeniy Ivanov <lolkaantimat@gmail.com> wrote:

> Hello,
> 
Hi,

> I have following cgroup hierarchy:
> 
>   Root
>   /   |
> A   B
> 
> A and B have memory limits set so that it's 100% of limit set in Root.
> I want to add C to root:
> 
>   Root
>   /   |  \
> A   B  C
> 
> What is correct way to shrink limits for A and B? When they use all
> allowed memory and I try to write to their limit files I get error. 

What kinds of error ? Do you have swap ? What is the kerenel version ?

> It seems, that I can shrink their limits multiple times by 1Mb and it
> works, but looks ugly and like very dirty workaround.
> 

It's designed to allow "shrink at once" but that means release memory
and do forced-writeback. To release memory, it may have to write back
to swap. If tasks in "A" and "B" are too busy and tocuhes tons of memory
while shrinking, it may fail.

It may be a regression. Kernel version is important.

Could you show memory.stat file when you shrink "A" and "B" ?
And what happnes
# sync
# sync
# sync
# reduce memory A
# reduce memory B

one by one ?
Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
