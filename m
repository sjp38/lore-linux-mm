Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A39B38D0001
	for <linux-mm@kvack.org>; Thu,  4 Nov 2010 22:17:59 -0400 (EDT)
Received: by qwi2 with SMTP id 2so2001380qwi.14
        for <linux-mm@kvack.org>; Thu, 04 Nov 2010 19:17:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1288831858.23014.129.camel@sli10-conroe>
References: <1288831858.23014.129.camel@sli10-conroe>
Date: Fri, 5 Nov 2010 11:17:55 +0900
Message-ID: <AANLkTi=YRJ8EN0V0msNJz6ChT1Ao6Qbhx2hmyZsd+oaV@mail.gmail.com>
Subject: Re: [patch]vmscan: avoid set zone congested if no page dirty
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, mel <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 4, 2010 at 9:50 AM, Shaohua Li <shaohua.li@intel.com> wrote:
> nr_dirty and nr_congested are increased only when page is dirty. So if all pages
> are clean, both them will be zero. In this case, we should not mark the zone
> congested.
>
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
