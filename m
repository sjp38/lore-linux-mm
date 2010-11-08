Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 009966B004A
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 04:08:55 -0500 (EST)
Date: Mon, 8 Nov 2010 10:08:21 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 4/4] memcg: use native word page statistics counters
Message-ID: <20101108090820.GI23393@cmpxchg.org>
References: <1288973333-7891-1-git-send-email-minchan.kim@gmail.com>
 <20101106010357.GD23393@cmpxchg.org>
 <AANLkTin9m65JVKRuStZ1-qhU5_1AY-GcbBRC0TodsfYC@mail.gmail.com>
 <20101107215030.007259800@cmpxchg.org>
 <20101107220353.964566018@cmpxchg.org>
 <AANLkTinLK5DiG3ZkEFSAJNZrPKK7aXiPPYQ6z9M6RPhc@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTinLK5DiG3ZkEFSAJNZrPKK7aXiPPYQ6z9M6RPhc@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Young <hidave.darkstar@gmail.com>, Andrea Righi <arighi@develer.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 08, 2010 at 09:01:54AM +0900, Minchan Kim wrote:
> On Mon, Nov 8, 2010 at 7:14 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > The statistic counters are in units of pages, there is no reason to
> > make them 64-bit wide on 32-bit machines.
> >
> > Make them native words.  Since they are signed, this leaves 31 bit on
> > 32-bit machines, which can represent roughly 8TB assuming a page size
> > of 4k.
> >
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> 
> This patch changes mem_cgroup_recursive_idx_stat with
> mem_cgroup_recursive_stat as well.
> As you know, It would be better to be another patch although it's
> trivial. But I don't mind it.
> I like the name. :)

I also feel that it's not too nice to mix such cleanups with
functionality changes.  But I found the name too appalling to leave it
alone, and a separate patch not worth the trouble.

If somebody has strong feelings, I will happily split it up.

Thanks for your review, Minchan.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
