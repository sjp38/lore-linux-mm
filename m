Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E2ABE6B0092
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 21:00:24 -0500 (EST)
Date: Thu, 13 Jan 2011 10:57:41 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: cgroups and overcommit question
Message-Id: <20110113105741.dd38d58e.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <AANLkTin_-bH09WK43DS9p0Kpp=7y6iHbLnUrCtOc6Qy5@mail.gmail.com>
References: <AANLkTin_-bH09WK43DS9p0Kpp=7y6iHbLnUrCtOc6Qy5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Evgeniy Ivanov <lolkaantimat@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hi.

On Wed, 12 Jan 2011 18:40:37 +0300
Evgeniy Ivanov <lolkaantimat@gmail.com> wrote:

> Hello,
> 
> When I forbid memory overcommiting, malloc() returns 0 if can't
> reserve memory, but in a cgroup it will always succeed, when it can
> succeed when not in the group.
> E.g. I've set 2 to overcommit_memory, limit is 10M: I can ask malloc
> 100M and it will not return any error (kernel is 2.6.32).
> Is it expected behavior?
> 
Yes. Because memory cgroup can be used for limiting the memory(and swap) size
which is physically used, not the malloc'ed size.

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
