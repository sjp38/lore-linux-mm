Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 415FF6B0169
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 18:30:51 -0400 (EDT)
Received: by qyk7 with SMTP id 7so3155213qyk.14
        for <linux-mm@kvack.org>; Mon, 08 Aug 2011 15:30:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110808122255.GC14803@tiehlicka.suse.cz>
References: <20110727111002.9985.94938.stgit@localhost6>
	<20110808110207.30777.30800.stgit@localhost6>
	<20110808122255.GC14803@tiehlicka.suse.cz>
Date: Tue, 9 Aug 2011 07:30:48 +0900
Message-ID: <CAEwNFnD4GH0nr+7ngPBj2uG4jnKb20g3_wLO6HyvHj+vzt+Jzg@mail.gmail.com>
Subject: Re: [PATCH v2] vmscan: reverse lru scanning order
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Mon, Aug 8, 2011 at 9:22 PM, Michal Hocko <mhocko@suse.cz> wrote:
> On Mon 08-08-11 15:02:07, Konstantin Khlebnikov wrote:
>> LRU scanning order was accidentially changed in commit v2.6.27-5584-gb69408e:
>> "vmscan: Use an indexed array for LRU variables".
>> Before that commit reclaimer always scan active lists first.
>>
>> This patch just reverse it back.
>
> I am still not sure I see why the ordering matters that much.
> One thing that might matter is that shrink_list moves some pages from
> active to inactive list if inactive is low so it makes sense to try to
> shrink active before inactive. It would be a problem if inactive was
> almost empty. Then we would just waste time by shrinking inactive first.
> I am not sure how real problem is that, though.
>
> Whatever is the reason, I think it should be documented in the
> changelog.
> The change makes sense to me.
>

Absolutely agree with Michal.
I think the patch itself doesn't have a problem and even it is does make sense.
But we need changelog why we need it.
I don't want to overwrite recent git log without any issue.
It annoys us when we find a bug by git-blame. ;-)
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
