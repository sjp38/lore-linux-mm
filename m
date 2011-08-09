Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 407996B0169
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 04:08:56 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 4D47C3EE0BC
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 17:08:53 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3519B45DE62
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 17:08:53 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 01FF545DE5D
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 17:08:53 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D78B51DB804E
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 17:08:52 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A06541DB804F
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 17:08:52 +0900 (JST)
Date: Tue, 9 Aug 2011 17:01:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3] memcg: add memory.vmscan_stat
Message-Id: <20110809170118.880377f8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110809080159.GA32015@redhat.com>
References: <20110722171540.74eb9aa7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110808124333.GA31739@redhat.com>
	<20110809083345.46cbc8de.kamezawa.hiroyu@jp.fujitsu.com>
	<20110809080159.GA32015@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, abrestic@google.com

On Tue, 9 Aug 2011 10:01:59 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> On Tue, Aug 09, 2011 at 08:33:45AM +0900, KAMEZAWA Hiroyuki wrote:
> > On Mon, 8 Aug 2011 14:43:33 +0200
> > Johannes Weiner <jweiner@redhat.com> wrote:
> > > On a non-technical note: as Ying Han and I were the other two people
> > > working on reclaim and statistics, it really irks me that neither of
> > > us were CCd on this.  Especially on such a controversial change.
> > 
> > I always drop CC if no reply/review comes.
> 
> There is always the possibility that a single mail in an otherwise
> unrelated patch series is overlooked (especially while on vacation ;).
> Getting CCd on revisions and -mm inclusion is a really nice reminder.
> 
> Unless there is a really good reason not to (is there ever?), could
> you please keep CCs?
> 

Ok, if you want, I'll CC always.
I myself just don't like to get 3 copies of mails when I don't have
much interests ;)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
