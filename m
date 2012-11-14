Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id E108C6B006C
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 20:22:35 -0500 (EST)
Date: Wed, 14 Nov 2012 02:22:34 +0100
From: Marc Duponcheel <marc@offline.be>
Subject: Re: [3.6 regression?] THP + migration/compaction livelock (I think)
Message-ID: <20121114012234.GB8152@offline.be>
Reply-To: Marc Duponcheel <marc@offline.be>
References: <CALCETrVgbx-8Ex1Q6YgEYv-Oxjoa1oprpsQE-Ww6iuwf7jFeGg@mail.gmail.com>
 <alpine.DEB.2.00.1211131507370.17623@chino.kir.corp.google.com>
 <CALCETrU=7+pk_rMKKuzgW1gafWfv6v7eQtVw3p8JryaTkyVQYQ@mail.gmail.com>
 <alpine.DEB.2.00.1211131530020.17623@chino.kir.corp.google.com>
 <CALCETrXSzNEdNEZaQqB93rpP9zXcBD4KRX_bjTAnzU6JEXcApg@mail.gmail.com>
 <alpine.DEB.2.00.1211131553170.17623@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1211131553170.17623@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Marc Duponcheel <marc@offline.be>

 Hi all, please let me know if there is are patches you want me to try.

 FWIW time did not stand still and I run 3.6.6 now.


On 2012 Nov 13, #David Rientjes wrote:
> On Tue, 13 Nov 2012, Andy Lutomirski wrote:
> 
> > >> $ grep -E "compact_|thp_" /proc/vmstat
> > >> compact_blocks_moved 8332448774
> > >> compact_pages_moved 21831286
> > >> compact_pagemigrate_failed 211260
> > >> compact_stall 13484
> > >> compact_fail 6717
> > >> compact_success 6755
> > >> thp_fault_alloc 150665
> > >> thp_fault_fallback 4270
> > >> thp_collapse_alloc 19771
> > >> thp_collapse_alloc_failed 2188
> > >> thp_split 19600
> > >>
> > >
> > > Two of the patches from the list provided at
> > > http://marc.info/?l=linux-mm&m=135179005510688 are already in your 3.6.3
> > > kernel:
> > >
> > >         mm: compaction: abort compaction loop if lock is contended or run too long
> > >         mm: compaction: acquire the zone->lock as late as possible
> > >
> > > and all have not made it to the 3.6 stable kernel yet, so would it be
> > > possible to try with 3.7-rc5 to see if it fixes the issue?  If so, it will
> > > indicate that the entire series is a candidate to backport to 3.6.
> > 
> > I'll try later on.  The last time I tried to boot 3.7 on this box, it
> > failed impressively (presumably due to a localmodconfig bug, but I
> > haven't tracked it down yet).
> > 
> > I'm also not sure how reliably I can reproduce this.
> > 
> 
> The challenge goes out to Marc too since he reported this issue on 3.6.2 
> but we haven't heard back yet on the success of the backport (although 
> it's probably easier to try 3.7-rc5 since there are some conflicts to 
> resolve).

--
 Marc Duponcheel
 Velodroomstraat 74 - 2600 Berchem - Belgium
 +32 (0)478 68.10.91 - marc@offline.be

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
