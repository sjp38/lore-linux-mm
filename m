Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id D01E96B007D
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 08:52:02 -0500 (EST)
Message-ID: <50C0A2EF.6010404@redhat.com>
Date: Thu, 06 Dec 2012 14:51:43 +0100
From: Zdenek Kabelac <zkabelac@redhat.com>
MIME-Version: 1.0
Subject: Re: kswapd craziness in 3.7
References: <1354049315-12874-1-git-send-email-hannes@cmpxchg.org> <20121128094511.GS8218@suse.de> <50BCC3E3.40804@redhat.com> <20121203191858.GY24381@cmpxchg.org> <50BDBCD9.9060509@redhat.com>
In-Reply-To: <50BDBCD9.9060509@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, George Spelvin <linux@horizon.com>, Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, Thorsten Leemhuis <fedora@leemhuis.info>, Tomas Racek <tracek@redhat.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Josh Boyer <jwboyer@gmail.com>, Valdis.Kletnieks@vt.edu, Jiri Slaby <jslaby@suse.cz>, Bruno Wolff III <bruno@wolff.to>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Dne 4.12.2012 10:05, Zdenek Kabelac napsal(a):
> Dne 3.12.2012 20:18, Johannes Weiner napsal(a):
>> Szia Zdenek,
>>
>> On Mon, Dec 03, 2012 at 04:23:15PM +0100, Zdenek Kabelac wrote:
>>> Ok, bad news - I've been hit by  kswapd0 loop again -
>>> my kernel git commit cc19528bd3084c3c2d870b31a3578da8c69952f3 again
>>> shown kswapd0 for couple minutes on CPU.
>>>
>>> It seemed to go instantly away when I've drop caches
>>> (echo 3 >/proc/sys/vm/drop_cache)
>>> (After that I've had over 1G free memory)
>>
>> Any chance you could retry with this patch on top?
>>
>> ---
>> From: Johannes Weiner <hannes@cmpxchg.org>
>> Subject: [patch] mm: vmscan: do not keep kswapd looping forever due
>>   to individual uncompactable zones
>>
>> ---
>>   mm/vmscan.c | 16 ----------------
>>   1 file changed, 16 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>
>
> Ok, I'm running now b69f0859dc8e633c5d8c06845811588fe17e68b3 (-rc8)
> with your patch.  I'll be able to give some feedback after couple
> days (if I keep my machine running without reboot - since before

So to just give some positive info -

with  2 1/2 day uptime, several suspend/resumes, ff at 1.4GB
I still have just 29 seconds for kswapd0 process.

So the patch above might have helped - but I'll look for a few more days.

Zdenek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
