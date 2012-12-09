Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 7AD456B0074
	for <linux-mm@kvack.org>; Sat,  8 Dec 2012 20:01:58 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so1172104pbc.14
        for <linux-mm@kvack.org>; Sat, 08 Dec 2012 17:01:57 -0800 (PST)
Date: Sat, 8 Dec 2012 17:01:42 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: kswapd craziness in 3.7
In-Reply-To: <50C3AF80.8040700@iskon.hr>
Message-ID: <alpine.LFD.2.02.1212081651270.4593@air.linux-foundation.org>
References: <20121128145215.d23aeb1b.akpm@linux-foundation.org> <20121128235412.GW8218@suse.de> <50B77F84.1030907@leemhuis.info> <20121129170512.GI2301@cmpxchg.org> <50B8A8E7.4030108@leemhuis.info> <20121201004520.GK2301@cmpxchg.org> <50BC6314.7060106@leemhuis.info>
 <20121203194208.GZ24381@cmpxchg.org> <20121204214210.GB20253@cmpxchg.org> <20121205030133.GA17438@wolff.to> <20121206173742.GA27297@wolff.to> <CA+55aFzZsCUk6snrsopWQJQTXLO__G7=SjrGNyK3ePCEtZo7Sw@mail.gmail.com> <50C32D32.6040800@iskon.hr>
 <50C3AF80.8040700@iskon.hr>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zlatko Calusic <zlatko.calusic@iskon.hr>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>



On Sat, 8 Dec 2012, Zlatko Calusic wrote:
> 
> Or sooner... in short: nothing's changed!
> 
> On a 4GB RAM system, where applications use close to 2GB, kswapd likes to keep
> around 1GB free (unused), leaving only 1GB for page/buffer cache. If I force
> bigger page cache by reading a big file and thus use the unused 1GB of RAM,
> kswapd will soon (in a matter of minutes) evict those (or other) pages out and
> once again keep unused memory close to 1GB.

Ok, guys, what was the reclaim or kswapd patch during the merge window 
that actually caused all of these insane problems? It seems it was more 
fundamentally buggered than the fifteen-million fixes for kswapd we have 
already picked up.

(Ok, I may be exaggerating the number of patches, but it's starting to 
feel that way - I thought that 3.7 was going to be a calm and easy 
release, but the kswapd issues seem to just keep happening. We've been 
fighting the kswapd changes for a while now.)

Trying to keep a gigabyte free (presumably because that way we have lots 
of high-order alloction pages) is ridiculous. Is it one of the compaction 
changes? 

Mel? Ideas?

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
