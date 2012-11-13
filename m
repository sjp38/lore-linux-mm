Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 7B3FF6B004D
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 18:41:05 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so5902892pad.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 15:41:04 -0800 (PST)
Date: Tue, 13 Nov 2012 15:41:02 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [3.6 regression?] THP + migration/compaction livelock (I
 think)
In-Reply-To: <CALCETrU=7+pk_rMKKuzgW1gafWfv6v7eQtVw3p8JryaTkyVQYQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1211131530020.17623@chino.kir.corp.google.com>
References: <CALCETrVgbx-8Ex1Q6YgEYv-Oxjoa1oprpsQE-Ww6iuwf7jFeGg@mail.gmail.com> <alpine.DEB.2.00.1211131507370.17623@chino.kir.corp.google.com> <CALCETrU=7+pk_rMKKuzgW1gafWfv6v7eQtVw3p8JryaTkyVQYQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Marc Duponcheel <marc@offline.be>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 13 Nov 2012, Andy Lutomirski wrote:

> It just happened again.
> 
> $ grep -E "compact_|thp_" /proc/vmstat
> compact_blocks_moved 8332448774
> compact_pages_moved 21831286
> compact_pagemigrate_failed 211260
> compact_stall 13484
> compact_fail 6717
> compact_success 6755
> thp_fault_alloc 150665
> thp_fault_fallback 4270
> thp_collapse_alloc 19771
> thp_collapse_alloc_failed 2188
> thp_split 19600
> 

Two of the patches from the list provided at
http://marc.info/?l=linux-mm&m=135179005510688 are already in your 3.6.3 
kernel:

	mm: compaction: abort compaction loop if lock is contended or run too long
	mm: compaction: acquire the zone->lock as late as possible

and all have not made it to the 3.6 stable kernel yet, so would it be 
possible to try with 3.7-rc5 to see if it fixes the issue?  If so, it will 
indicate that the entire series is a candidate to backport to 3.6.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
