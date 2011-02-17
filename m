Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A88D88D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 00:47:30 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D3B283EE0BB
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 14:47:28 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B7D2145DE59
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 14:47:28 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E60045DE54
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 14:47:28 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C6DEE08006
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 14:47:28 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 531AAE08003
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 14:47:28 +0900 (JST)
Date: Thu, 17 Feb 2011 14:41:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v2 1/2] memcg: break out event counters from other stats
Message-Id: <20110217144116.58d71a7d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110217143315.858dd090.kamezawa.hiroyu@jp.fujitsu.com>
References: <1297920842-17299-1-git-send-email-gthelen@google.com>
	<1297920842-17299-2-git-send-email-gthelen@google.com>
	<20110217143315.858dd090.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 17 Feb 2011 14:33:15 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 16 Feb 2011 21:34:01 -0800
> Greg Thelen <gthelen@google.com> wrote:
> 
> > From: Johannes Weiner <hannes@cmpxchg.org>
> > 
> > For increasing and decreasing per-cpu cgroup usage counters it makes
> > sense to use signed types, as single per-cpu values might go negative
> > during updates.  But this is not the case for only-ever-increasing
> > event counters.
> > 
> > All the counters have been signed 64-bit so far, which was enough to
> > count events even with the sign bit wasted.
> > 
> > The next patch narrows the usage counters type (on 32-bit CPUs, that
> > is), though, so break out the event counters and make them unsigned
> > words as they should have been from the start.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > Signed-off-by: Greg Thelen <gthelen@google.com>
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 

Hmm..but not mentioning the change "s64 -> unsigned long(may 32bit)" clearly
isn't good behavior. 

Could you clarify both of changes in patch description as
==
This patch
  - devides counters to signed and unsigned ones(increase only).
  - makes unsigned one to be 'unsigned long' rather than 'u64'
and
  - then next patch will make 'signed' part to be 'long'
==
for changelog ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
