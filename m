Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 3513A6B0006
	for <linux-mm@kvack.org>; Fri,  8 Mar 2013 10:26:02 -0500 (EST)
Message-ID: <513A02FC.4070208@genband.com>
Date: Fri, 08 Mar 2013 09:25:48 -0600
From: Chris Friesen <chris.friesen@genband.com>
MIME-Version: 1.0
Subject: Re: mmap vs fs cache
References: <5136320E.8030109@symas.com> <20130307154312.GG6723@quack.suse.cz> <20130308020854.GC23767@cmpxchg.org> <5139975F.9070509@symas.com> <20130308084246.GA4411@shutemov.name> <5139B214.3040303@symas.com> <5139FA13.8090305@genband.com> <5139FD27.1030208@symas.com>
In-Reply-To: <5139FD27.1030208@symas.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Howard Chu <hyc@symas.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 03/08/2013 09:00 AM, Howard Chu wrote:

> First obvious conclusion - kswapd is being too aggressive. When free
> memory hits the low watermark, the reclaim shrinks slapd down from 25GB
> to 18-19GB, while the page cache still contains ~7GB of unmapped pages.
> Ideally I'd like a tuning knob so I can say to keep no more than 2GB of
> unmapped pages in the cache. (And the desired effect of that would be to
> allow user processes to grow to 30GB total, in this case.)
>
> I mentioned this "unmapped page cache control" post already
> http://lwn.net/Articles/436010/ but it seems that the idea was
> ultimately rejected. Is there anything else similar in current kernels?

Sorry, I'm not aware of anything.  I'm not a filesystem/vm guy though, 
so maybe there's something I don't know about.

I would have expected both posix_madvise(..POSIX_MADV_RANDOM) and 
swappiness to help, but it doesn't sound like they're working.

Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
