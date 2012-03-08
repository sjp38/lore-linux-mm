Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 0C4346B007E
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 00:37:53 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 1D9863EE0C2
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 14:37:52 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0242645DEB5
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 14:37:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D25EF45DEAD
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 14:37:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C2DE91DB8044
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 14:37:51 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 781571DB803E
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 14:37:51 +0900 (JST)
Date: Thu, 8 Mar 2012 14:36:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 6/7] mm/memcg: rework inactive_ratio calculation
Message-Id: <20120308143619.4f25880e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4F50678C.6010800@openvz.org>
References: <20120229090748.29236.35489.stgit@zurg>
	<20120229091600.29236.69514.stgit@zurg>
	<20120302143106.d4238cda.kamezawa.hiroyu@jp.fujitsu.com>
	<4F50678C.6010800@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, 02 Mar 2012 10:24:12 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> KAMEZAWA Hiroyuki wrote:
> > On Wed, 29 Feb 2012 13:16:00 +0400
> > Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:
> >
> >> This patch removes precalculated zone->inactive_ratio.
> >> Now it always calculated in inactive_anon_is_low() from current lru size.
> >> After that we can merge memcg and non-memcg cases and drop duplicated code.
> >>
> >> We can drop precalculated ratio, because its calculation fast enough to do it
> >> each time. Plus precalculation uses zone size as basis, this estimation not
> >> always match with page lru size, for example if a significant proportion
> >> of memory occupied by kernel objects.om memory cgroup which is triggered this memory reclaim.
> This is more reason
> >>
> >> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
> >
> > Maybe good....but please don't change the user interface /proc/zoneinfo implicitly.
> > How about calculating inactive_ratio at reading /proc/zoneinfo ?
> 
> I don't know... Anybody need this?

I don't like changes in user interface without any caution in feature-removal-schedule.txt
I just don't Ack. If others say ok, please go ahead with them.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
