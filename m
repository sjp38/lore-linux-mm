Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5CEC26008E4
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 00:02:29 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o733wTC3012196
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 21:58:29 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7346qn8103484
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 22:06:53 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7346lmD010686
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 22:06:48 -0600
Date: Tue, 3 Aug 2010 09:36:45 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -mm 5/5] memcg: use spinlock in page_cgroup instead of
 bit_spinlock
Message-ID: <20100803040645.GH3863@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100802191113.05c982e4.kamezawa.hiroyu@jp.fujitsu.com>
 <20100802192006.a395889a.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100802192006.a395889a.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, vgoyal@redhat.com, m-ikeda@ds.jp.nec.com, gthelen@google.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-08-02 19:20:06]:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> This patch replaces bit_spinlock with spinlock. In general,
> spinlock has good functinality than bit_spin_lock and we should use
> it if we have a room for it. In 64bit arch, we have extra 4bytes.
> Let's use it.
> expected effects:
>  - use better codes.
>  - ticket lock on x86-64
>  - para-vitualization aware lock
> etc..
> 
> Chagelog: 20090729
>  - fixed page_cgroup_is_locked().
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> --

The additional space usage is a big concern, I think saving space
would be of highest priority. I understand the expected benefits, but
a spinlock_t per page_cgroup is quite expensive at the moment. If
anything I think it should be a config option under CONFIG_DEBUG or
something else to play with and see the side effects.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
