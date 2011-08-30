Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 5BB2E6B00EE
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 19:52:45 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 116343EE0AE
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 08:52:42 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E454445DEAD
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 08:52:41 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CC83045DE9E
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 08:52:41 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B93A51DB8037
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 08:52:41 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 82BBB1DB8038
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 08:52:41 +0900 (JST)
Date: Wed, 31 Aug 2011 08:38:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] Revert "memcg: add memory.vmscan_stat"
Message-Id: <20110831083843.25d744bc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110830110337.GE13061@redhat.com>
References: <20110808124333.GA31739@redhat.com>
	<20110809083345.46cbc8de.kamezawa.hiroyu@jp.fujitsu.com>
	<20110829155113.GA21661@redhat.com>
	<20110830101233.ae416284.kamezawa.hiroyu@jp.fujitsu.com>
	<20110830070424.GA13061@redhat.com>
	<20110830162050.f6c13c0c.kamezawa.hiroyu@jp.fujitsu.com>
	<20110830084245.GC13061@redhat.com>
	<20110830175609.4977ef7a.kamezawa.hiroyu@jp.fujitsu.com>
	<20110830101726.GD13061@redhat.com>
	<20110830193406.361d758a.kamezawa.hiroyu@jp.fujitsu.com>
	<20110830110337.GE13061@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Andrew Brestic <abrestic@google.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 30 Aug 2011 13:03:37 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> On Tue, Aug 30, 2011 at 07:34:06PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Tue, 30 Aug 2011 12:17:26 +0200
> > Johannes Weiner <jweiner@redhat.com> wrote:

> > How about fixing interface first ? 1st version of this patch was 
> > in April and no big change since then.
> > I don't want to be starved more.
> 
> Back then I mentioned all my concerns and alternate suggestions.
> Different from you, I explained and provided a reason for every single
> counter I wanted to add, suggested a basic pattern for how to
> interpret them to gain insight into memcg configurations and their
> behaviour.  No reaction.  If you want to make progress, than don't
> ignore concerns and arguments.  If my arguments are crap, then tell me
> why and we can move on.
> 

I think having percpu couneter has no performance benefit, just lose
extra memory by percpu allocation.
Anyway, you can change internal implemenatation when it's necessary.

But Ok, I agree using the same style as zone counters is better.

> What we have now is not ready.  It wasn't discussed properly, which
> certainly wasn't for the lack of interest in this change.  I just got
> tired of raising the same points over and over again without answer.
> 
> The amount of time a change has been around is not an argument for it
> to get merged.  On the other hand, the fact that it hasn't changed
> since April *even though* the implementation was opposed back then
> doesn't really speak for your way of getting this upstream, does it?

The fact is that you should revert the patch when it's merged to mmotm.

Please revert patch. And merge your own.
Anyway I don't have much interests in hierarchy.

Bye,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
