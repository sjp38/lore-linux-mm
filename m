Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id B3C626B004D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 10:05:48 -0500 (EST)
Message-ID: <4F05BC1F.7070009@redhat.com>
Date: Thu, 05 Jan 2012 10:05:03 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3.2.0-rc1 2/3] MM hook for page allocation and release
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com> <e78b4ac9d3d51ac16180114c08733e4bf62ec65e.1325696593.git.leonid.moiseichuk@nokia.com> <20120105155950.9e49651b.kamezawa.hiroyu@jp.fujitsu.com> <84FF21A720B0874AA94B46D76DB9826904554270@008-AM1MPN1-003.mgdnok.nokia.com> <CAOJsxLF706VeThxqWostJr84N_8q8UXoQzxGmMXj8mpgTLCagg@mail.gmail.com>
In-Reply-To: <CAOJsxLF706VeThxqWostJr84N_8q8UXoQzxGmMXj8mpgTLCagg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: leonid.moiseichuk@nokia.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, emunson@mgebm.net, aarcange@redhat.com, mel@csn.ul.ie, rientjes@google.com, dima@android.com, gregkh@suse.de, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

On 01/05/2012 07:49 AM, Pekka Enberg wrote:
> On Thu, Jan 5, 2012 at 1:26 PM,<leonid.moiseichuk@nokia.com>  wrote:
>> I agree that hooking alloc_pages is ugly way. So alternatives I see:
>>
>> - shrinkers (as e.g. Android OOM used) but shrink_slab called only from
>> try_to_free_pages only if we are on slow reclaim path on memory allocation,
>> so it cannot be used for e.g. 75% memory tracking or when pages released to
>> notify user space that we are OK. But according to easy to use it will be the
>> best approach.

Well, there is always the page cache.

If, at reclaim time, the amount of page cache + free memory
is below the free threshold, we should still have space left
to handle userspace things.

It may be possible to hijack memcg accounting to get lower
usage thresholds for earlier notification.  That way the code
can stay out of the true fast paths like alloc_pages.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
