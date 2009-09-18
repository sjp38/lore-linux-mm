Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4E4286B00CB
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 06:37:21 -0400 (EDT)
Date: Fri, 18 Sep 2009 19:37:21 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [RFC][PATCH 0/11][mmotm] memcg: patch dump (Sep/18)
Message-Id: <20090918193721.a99042fb.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20090918174757.672f1e8e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090909173903.afc86d85.kamezawa.hiroyu@jp.fujitsu.com>
	<20090918174757.672f1e8e.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, d-nishimura@mtf.biglobe.ne.jp
List-ID: <linux-mm.kvack.org>

On Fri, 18 Sep 2009 17:47:57 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Posting just for dumping my stack, plz see if you have time.
> (will repost, this set is not for any merge)
> 
> Because my office is closed until next Thursday, my RTT will be long for a while.
> 
> Patches are mainly in 3 parts.
>  - soft-limit modification (1,2)
>  - coalescing chages (3,4)
>  - cleanups. (5-11)
> 
> In these days, I feel I have to make memcgroup.c cleaner.
> Some comments are old and placement of functions are at random.
> 
> Patches are still messy but plz see applied image if you interested in.
> 
> 1. fix up softlimit's uncharge path
> 2. fix up softlimit's charge path
> 3. coalescing uncharge path
> 4. coalescing charge path
> 5. memcg_charge_cancel ....from Nishimura's set. this is very nice.
Thank you for including this one.
I'll leave this patch to you.

> 6. clean up percpu statistics of memcg.
> 7. clean up mem_cgroup_from_xxxx functions.
> 8. adds commentary and remove unused macros.
> 9. clean up for mem_cgroup's per-zone stat
> 10. adds commentary for soft-limit and moves functions for per-cpu 
> 11. misc. commentary and function replacement...not sorted out well.
> 
> Patches in 6-11 sounds like bad-news for Nishimura-san, but I guess
> no heavy hunk you'll have...
> 
Don't worry, do it as you like :)
I've read through these patches briefly, I don't think it's so difficult
to re-base my patches on them. And they are good clean up, IMHO.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
