Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 37E3D6B005D
	for <linux-mm@kvack.org>; Sun,  9 Dec 2012 16:59:57 -0500 (EST)
Received: by mail-we0-f169.google.com with SMTP id t49so1174736wey.14
        for <linux-mm@kvack.org>; Sun, 09 Dec 2012 13:59:55 -0800 (PST)
Message-ID: <50C509D3.3070108@gmail.com>
Date: Sun, 09 Dec 2012 22:59:47 +0100
From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
MIME-Version: 1.0
Subject: Re: kswapd craziness in 3.7
References: <20121128145215.d23aeb1b.akpm@linux-foundation.org> <20121128235412.GW8218@suse.de> <50B77F84.1030907@leemhuis.info> <20121129170512.GI2301@cmpxchg.org> <50B8A8E7.4030108@leemhuis.info> <20121201004520.GK2301@cmpxchg.org> <50BC6314.7060106@leemhuis.info> <20121203194208.GZ24381@cmpxchg.org> <20121204214210.GB20253@cmpxchg.org> <20121205030133.GA17438@wolff.to> <20121206173742.GA27297@wolff.to> <CA+55aFzZsCUk6snrsopWQJQTXLO__G7=SjrGNyK3ePCEtZo7Sw@mail.gmail.com> <50C32D32.6040800@iskon.hr> <50C3AF80.8040700@iskon.hr> <alpine.LFD.2.02.1212081651270.4593@air.linux-foundation.org>
In-Reply-To: <alpine.LFD.2.02.1212081651270.4593@air.linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Zlatko Calusic <zlatko.calusic@iskon.hr>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Dne 9.12.2012 02:01, Linus Torvalds napsal(a):
>
>
> On Sat, 8 Dec 2012, Zlatko Calusic wrote:
>>
>> Or sooner... in short: nothing's changed!
>>
>> On a 4GB RAM system, where applications use close to 2GB, kswapd likes to keep
>> around 1GB free (unused), leaving only 1GB for page/buffer cache. If I force
>> bigger page cache by reading a big file and thus use the unused 1GB of RAM,
>> kswapd will soon (in a matter of minutes) evict those (or other) pages out and
>> once again keep unused memory close to 1GB.
>
> Ok, guys, what was the reclaim or kswapd patch during the merge window
> that actually caused all of these insane problems? It seems it was more
> fundamentally buggered than the fifteen-million fixes for kswapd we have
> already picked up.
>
> (Ok, I may be exaggerating the number of patches, but it's starting to
> feel that way - I thought that 3.7 was going to be a calm and easy
> release, but the kswapd issues seem to just keep happening. We've been
> fighting the kswapd changes for a while now.)
>
> Trying to keep a gigabyte free (presumably because that way we have lots
> of high-order alloction pages) is ridiculous. Is it one of the compaction
> changes?
>
> Mel? Ideas?
>

Very true

It's just as simple a making

dd if=/dev/zero of=/tmp/zero bs=1M count=0 seek=1000000

and now

dd if=/tmp/zero of=/dev/null bs=1M

and kswapd fights with dd  for CPU time....


Zdenek


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
