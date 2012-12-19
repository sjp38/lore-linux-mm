Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 73D996B0068
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 17:24:06 -0500 (EST)
Date: Wed, 19 Dec 2012 23:24:00 +0100
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
MIME-Version: 1.0
References: <20121203194208.GZ24381@cmpxchg.org> <20121204214210.GB20253@cmpxchg.org> <20121205030133.GA17438@wolff.to> <20121206173742.GA27297@wolff.to> <CA+55aFzZsCUk6snrsopWQJQTXLO__G7=SjrGNyK3ePCEtZo7Sw@mail.gmail.com> <50C32D32.6040800@iskon.hr> <50C3AF80.8040700@iskon.hr> <alpine.LFD.2.02.1212081651270.4593@air.linux-foundation.org> <20121210110337.GH1009@suse.de> <20121210163904.GA22101@cmpxchg.org> <20121210180141.GK1009@suse.de> <50C62AE6.3030000@iskon.hr> <CA+55aFwNE2y5t2uP3esCnHsaNo0NTDnGvzN6KF0qTw_y+QbtFA@mail.gmail.com> <50C6477A.4090005@iskon.hr> <50C67C13.6090702@iskon.hr>
In-Reply-To: <50C67C13.6090702@iskon.hr>
Message-ID: <50D23E80.3010408@iskon.hr>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Subject: Re: kswapd craziness in 3.7
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

On 11.12.2012 01:19, Zlatko Calusic wrote:
>> On 10.12.2012 20:13, Linus Torvalds wrote:
>>>
>>> It's worth giving this as much testing as is at all possible, but at
>>> the same time I really don't think I can delay 3.7 any more without
>>> messing up the holiday season too much. So unless something obvious
>>> pops up, I will do the release tonight. So testing will be minimal -
>>> but it's not like we haven't gone back-and-forth on this several times
>>> already, and we revert to *mostly* the same old state as 3.6 anyway,
>>> so it should be fairly safe.
>>>
>
> So, here's what I found. In short: close, but no cigar!
>
> Kswapd is certainly no more CPU pig, and memory seems to be utilized
> properly (the kernel still likes to keep 400MB free, somebody else can
> confirm if that's to be expected on a 4GB THP-enabled machine). So it
> looks very decent, and much better than anything I run in last 10 days,
> barring !THP kernel.
>
> What remains a mystery is that kswapd occassionaly still likes to get
> stuck in a D state, only now it recovers faster than before (sometimes
> in a matter of seconds, but sometimes it takes a few minutes). Now, I
> admit it's a small, maybe even cosmetic issue. But, it could also be a
> warning sign of a bigger problem that will reveal itself on a more
> loaded machine.
>

Ha, I nailed it!

The cigar aka the explanation together with a patch will follow shortly 
in a separate topic.

It's a genuine bug that has been with us for a long long time.
-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
