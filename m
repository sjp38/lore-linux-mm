Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1E8446B007E
	for <linux-mm@kvack.org>; Tue, 12 Jul 2011 11:43:51 -0400 (EDT)
Date: Tue, 12 Jul 2011 10:43:47 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] mm: vmscan: Do use use PF_SWAPWRITE from
 zone_reclaim
In-Reply-To: <CAEwNFnAprEuZJucDSMgnUHGePyxgyRqNCWOsG0-K2nTjmKcUug@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1107121042240.2530@router.home>
References: <1310389274-13995-1-git-send-email-mgorman@suse.de> <1310389274-13995-2-git-send-email-mgorman@suse.de> <CAEwNFnATXiQsmbfuvZNEtcpcVZkyZKRFB1SKbkEREaCW4S-aUg@mail.gmail.com> <4E1C1684.4090706@jp.fujitsu.com>
 <CAEwNFnAprEuZJucDSMgnUHGePyxgyRqNCWOsG0-K2nTjmKcUug@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 12 Jul 2011, Minchan Kim wrote:

> If I am not against this patch, at least, we need agreement of
> Christoph and others and if we agree this change, we changes vm.txt,
> too.

I think PF_SWAPWRITE should only be set if may_write was set earlier in
__zone_reclaim. If zone reclaim is not configured to do writeback then it
makes no sense to set the bit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
