Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 9CC7C6B0102
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 16:14:49 -0400 (EDT)
Message-ID: <4F6793B0.50601@redhat.com>
Date: Mon, 19 Mar 2012 16:14:40 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: forbid lumpy-reclaim in shrink_active_list()
References: <20120319091821.17716.54031.stgit@zurg> <4F676FA4.50905@redhat.com> <4F6773CC.2010705@openvz.org> <4F6774E8.2050202@redhat.com> <alpine.LSU.2.00.1203191239570.3498@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1203191239570.3498@eggly.anvils>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 03/19/2012 04:05 PM, Hugh Dickins wrote:
> On Mon, 19 Mar 2012, Rik van Riel wrote:

>> It was done that way, because Mel explained to me that deactivating
>> a whole chunk of active pages at once is a desired feature that makes
>> it more likely that a whole contiguous chunk of pages will eventually
>> reach the end of the inactive list.
>
> I'm rather sceptical about this: is there a test which demonstrates
> a useful effect of that kind?

I am somewhat sceptical too, but since lumpy reclaim is
due to be removed anyway, I did not bother to investigate
its behaviour in any detail :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
