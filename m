Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id E34086B005A
	for <linux-mm@kvack.org>; Tue,  3 Jan 2012 19:03:16 -0500 (EST)
Received: by ghrr18 with SMTP id r18so10811641ghr.14
        for <linux-mm@kvack.org>; Tue, 03 Jan 2012 16:03:16 -0800 (PST)
Message-ID: <4F039742.1000703@gmail.com>
Date: Tue, 03 Jan 2012 19:03:14 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: take pagevecs off reclaim stack
References: <alpine.LSU.2.00.1112282028160.1362@eggly.anvils> <alpine.LSU.2.00.1112282037000.1362@eggly.anvils> <20111229145548.e34cb2f3.akpm@linux-foundation.org> <alpine.LSU.2.00.1112291510390.4888@eggly.anvils> <4EFD04B2.7050407@gmail.com> <alpine.LSU.2.00.1112291753350.3614@eggly.anvils> <20111229195917.13f15974.akpm@linux-foundation.org> <alpine.LSU.2.00.1112312302010.18500@eggly.anvils> <20120103151236.893d2460.akpm@linux-foundation.org> <4F038C97.606@gmail.com> <20120103152919.f7348ffb.akpm@linux-foundation.org>
In-Reply-To: <20120103152919.f7348ffb.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>

(1/3/12 6:29 PM), Andrew Morton wrote:
> On Tue, 03 Jan 2012 18:17:43 -0500
> KOSAKI Motohiro<kosaki.motohiro@gmail.com>  wrote:
>
>>>> I'm sure there are better reasons for removing lumpy than that I posted
>>>> a patch which happened to remove some limitation.  No need to poke Mel
>>>> on my behalf!
>>>
>>> No harm done - Mel's been getting rather unpoked lately.
>>>
>>> Not that poking works very well anyway<checks to see if mm/thrash.c
>>> is still there>
>>
>> Maybe I touched mm/thrash.c at last. Do you have any problem in it?
>>
>
> https://lkml.org/lkml/2011/8/27/13
>
> The thrash detection logic was accidentally disabled over a year ago,
> and nobody has noticed.  To me, this information says "kill it".

Thanks, I'm looking at it later.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
