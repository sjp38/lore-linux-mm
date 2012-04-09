Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 5EDB16B007E
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 14:10:10 -0400 (EDT)
Message-ID: <4F8325FB.80409@redhat.com>
Date: Mon, 09 Apr 2012 14:10:03 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/2] Removal of lumpy reclaim
References: <1332950783-31662-1-git-send-email-mgorman@suse.de> <20120406123439.d2ba8920.akpm@linux-foundation.org> <alpine.LSU.2.00.1204061316580.3057@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1204061316580.3057@eggly.anvils>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>

On 04/06/2012 04:31 PM, Hugh Dickins wrote:
> On Fri, 6 Apr 2012, Andrew Morton wrote:
>> On Wed, 28 Mar 2012 17:06:21 +0100
>> Mel Gorman<mgorman@suse.de>  wrote:
>>
>>> (cc'ing active people in the thread "[patch 68/92] mm: forbid lumpy-reclaim
>>> in shrink_active_list()")
>>>
>>> In the interest of keeping my fingers from the flames at LSF/MM, I'm
>>> releasing an RFC for lumpy reclaim removal.
>>
>> I grabbed them, thanks.
>
> I do have a concern with this: I was expecting lumpy reclaim to be
> replaced by compaction, and indeed it is when CONFIG_COMPACTION=y.
> But when CONFIG_COMPACTION is not set, we're back to 2.6.22 in
> relying upon blind chance to provide order>0 pages.

Is this an issue for any architecture?

I could see NOMMU being unable to use compaction, but
chances are lumpy reclaim would be sufficient for that
configuration, anyway...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
