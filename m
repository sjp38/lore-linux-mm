Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 4AF746B0082
	for <linux-mm@kvack.org>; Fri, 18 May 2012 01:03:23 -0400 (EDT)
Received: by dakp5 with SMTP id p5so4941047dak.14
        for <linux-mm@kvack.org>; Thu, 17 May 2012 22:03:22 -0700 (PDT)
Message-ID: <4FB5D80B.8060000@gmail.com>
Date: Fri, 18 May 2012 13:03:07 +0800
From: Nai Xia <nai.xia@gmail.com>
Reply-To: nai.xia@gmail.com
MIME-Version: 1.0
Subject: Re: [patch 0/5] refault distance-based file cache sizing
References: <1335861713-4573-1-git-send-email-hannes@cmpxchg.org> <4FB33A4E.1010208@gmail.com> <4FB4F902.1050708@redhat.com>
In-Reply-To: <4FB4F902.1050708@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org



On 2012a1'05ae??17ae?JPY 21:11, Rik van Riel wrote:
> On 05/16/2012 01:25 AM, nai.xia wrote:
>> Hi Johannes,
>>
>> Just out of curiosity(since I didn't study deep into the
>> reclaiming algorithms), I can recall from here that around 2005,
>> there was an(or some?) implementation of the "Clock-pro" algorithm
>> which also have the idea of "reuse distance", but it seems that algo
>> did not work well enough to get merged?
>
> The main issue with clock-pro was scalability.
>
> Johannes has managed to take the good parts of clock-pro,
> and add it on top of our split lru VM, which lets us keep
> the scalability, while still being able to deal with file
> faults from beyond the inactive list.
>

Hmm, I see. Thanks for the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
