Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7C977900138
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 09:13:18 -0400 (EDT)
Date: Fri, 12 Aug 2011 15:13:14 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/2] mm: vmscan: fix force-scanning small targets without
 swap
Message-ID: <20110812131314.GC32335@tiehlicka.suse.cz>
References: <1313094715-31187-1-git-send-email-jweiner@redhat.com>
 <20110812131042.GB32335@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110812131042.GB32335@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Balbir Singh <bsingharora@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Mel Gorman <mel@csn.ul.ie>

On Fri 12-08-11 15:10:42, Michal Hocko wrote:
> On Thu 11-08-11 22:31:54, Johannes Weiner wrote:
> > Without swap, anonymous pages are not scanned.  As such, they should
> > not count when considering force-scanning a small target if there is
> > no swap.
> > 
> > Otherwise, targets are not force-scanned even when their effective
> > scan number is zero and the other conditions--kswapd/memcg--apply.
> > 
> > Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> 
> We are calculating nr_force_scan even if it is not needed but this
> shouldn't hurt.

Ahh and the second patch removes that calculation. Sorry for noise.

> Reviewed-by: Michal Hocko <mhocko@suse.cz>

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
