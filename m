Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 23E80900139
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 04:02:07 -0400 (EDT)
Date: Tue, 9 Aug 2011 10:01:59 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH v3] memcg: add memory.vmscan_stat
Message-ID: <20110809080159.GA32015@redhat.com>
References: <20110722171540.74eb9aa7.kamezawa.hiroyu@jp.fujitsu.com>
 <20110808124333.GA31739@redhat.com>
 <20110809083345.46cbc8de.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110809083345.46cbc8de.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, abrestic@google.com

On Tue, Aug 09, 2011 at 08:33:45AM +0900, KAMEZAWA Hiroyuki wrote:
> On Mon, 8 Aug 2011 14:43:33 +0200
> Johannes Weiner <jweiner@redhat.com> wrote:
> > On a non-technical note: as Ying Han and I were the other two people
> > working on reclaim and statistics, it really irks me that neither of
> > us were CCd on this.  Especially on such a controversial change.
> 
> I always drop CC if no reply/review comes.

There is always the possibility that a single mail in an otherwise
unrelated patch series is overlooked (especially while on vacation ;).
Getting CCd on revisions and -mm inclusion is a really nice reminder.

Unless there is a really good reason not to (is there ever?), could
you please keep CCs?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
