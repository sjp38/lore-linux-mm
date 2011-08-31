Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0BC2A6B016A
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 19:38:09 -0400 (EDT)
Date: Wed, 31 Aug 2011 16:37:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/2] mm: vmscan: fix force-scanning small targets
 without swap
Message-Id: <20110831163706.2b7ed5af.akpm@linux-foundation.org>
In-Reply-To: <20110829160839.GA22439@redhat.com>
References: <1313094715-31187-1-git-send-email-jweiner@redhat.com>
	<20110829160839.GA22439@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, Balbir Singh <bsingharora@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Mel Gorman <mel@csn.ul.ie>

On Mon, 29 Aug 2011 18:08:39 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> Andrew,
> 
> On Thu, Aug 11, 2011 at 10:31:54PM +0200, Johannes Weiner wrote:
> > Without swap, anonymous pages are not scanned.  As such, they should
> > not count when considering force-scanning a small target if there is
> > no swap.
> > 
> > Otherwise, targets are not force-scanned even when their effective
> > scan number is zero and the other conditions--kswapd/memcg--apply.
> 
> I forgot to mention, this patch is a fix for '246e87a memcg: fix
> get_scan_count() for small targets', which went upstream this merge
> window.
> 
> Probably makes sense to merge this one too before the release..?
> 

Ah, I didn't realise that.  Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
