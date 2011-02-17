Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A90E68D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 01:31:25 -0500 (EST)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp03.au.ibm.com (8.14.4/8.13.1) with ESMTP id p1H6QeWW006619
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 17:26:40 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p1H6VBoH2162714
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 17:31:11 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p1H6VB8d007872
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 17:31:11 +1100
Date: Thu, 17 Feb 2011 12:01:06 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 1/2] memcg: break out event counters from other stats
Message-ID: <20110217063106.GI3415@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1297920842-17299-1-git-send-email-gthelen@google.com>
 <1297920842-17299-2-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1297920842-17299-2-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

* Greg Thelen <gthelen@google.com> [2011-02-16 21:34:01]:

> From: Johannes Weiner <hannes@cmpxchg.org>
> 
> For increasing and decreasing per-cpu cgroup usage counters it makes
> sense to use signed types, as single per-cpu values might go negative
> during updates.  But this is not the case for only-ever-increasing
> event counters.
> 
> All the counters have been signed 64-bit so far, which was enough to
> count events even with the sign bit wasted.
> 
> The next patch narrows the usage counters type (on 32-bit CPUs, that
> is), though, so break out the event counters and make them unsigned
> words as they should have been from the start.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Greg Thelen <gthelen@google.com>
> ---

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 
-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
