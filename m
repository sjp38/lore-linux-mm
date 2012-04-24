Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 7750E6B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 12:45:49 -0400 (EDT)
Received: by dadq36 with SMTP id q36so1292614dad.8
        for <linux-mm@kvack.org>; Tue, 24 Apr 2012 09:45:48 -0700 (PDT)
Message-ID: <4F96D8C1.2060705@gmail.com>
Date: Tue, 24 Apr 2012 12:45:53 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] do_try_to_free_pages() might enter infinite loop
References: <1335214564-17619-1-git-send-email-yinghan@google.com> <CAHGf_=pGhtieRpUqbF4GmAKt5XXhf_2y8c+EzGNx-cgqPNvfJw@mail.gmail.com> <CALWz4ix+MC_NuNdvQU3T8BhP+BULPLktLyNQ8osnrMOa2nfhdw@mail.gmail.com> <4F960257.9090509@kernel.org> <CALWz4izoOYtNfRN3VBLSF7pyYyvjBPyiy865Xf+wvsCFwM6A7A@mail.gmail.com> <4F96D6EE.6000809@redhat.com>
In-Reply-To: <4F96D6EE.6000809@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Ying Han <yinghan@google.com>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, kosaki.motohiro@gmail.com

(4/24/12 12:38 PM), Rik van Riel wrote:
> On 04/24/2012 12:36 PM, Ying Han wrote:
>
>> However, what if B frees a pages everytime before pages_scanned
>> reaches the point, then we won't set zone->all_unreclaimable at all.
>> If so, we reaches a livelock here...
>
> If B keeps freeing pages, surely A will get a successful
> allocation and there will not be a livelock?

And, I hope we distinguish true livelock and pseudo livelock at first.
Nick's patch definitely makes kernel slowdown when OOM situation. It is
intentional. We thought slowdown is better than false positive OOM even
though the slowdown is extream slow and similar to livelock.

Ying, Which problem do you want to discuss? a) current kernrel has true
live lock b) current oom detection is too slow and livelock like and it
is not acceptable to you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
