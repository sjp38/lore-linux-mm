Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 11C0B6B004A
	for <linux-mm@kvack.org>; Fri,  6 Apr 2012 23:00:34 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so3755748pbc.14
        for <linux-mm@kvack.org>; Fri, 06 Apr 2012 20:00:33 -0700 (PDT)
Message-ID: <4F7FADC3.3000209@gmail.com>
Date: Fri, 06 Apr 2012 20:00:19 -0700
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/2] Removal of lumpy reclaim
References: <1332950783-31662-1-git-send-email-mgorman@suse.de> <20120406123439.d2ba8920.akpm@linux-foundation.org> <alpine.LSU.2.00.1204061316580.3057@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1204061316580.3057@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, kosaki.motohiro@gmail.com

(4/6/12 1:31 PM), Hugh Dickins wrote:
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

I was putted most big objection to remove lumpy when compaction merging. But
I think that's ok. Because of, desktop and server people always use COMPACTION=y
kernel and embedded people don't use swap (then lumpy wouldn't work).

My thought was to keep gradual development and avoid aggressive regression. and
Mel did. compaction is now completely stable and we have no reason to keep lumpy,
I think.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
