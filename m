Date: Tue, 23 Nov 2004 11:01:02 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: find_vma() cachehit rate
Message-ID: <20041123130102.GA5268@logos.cnet>
References: <200411211054.53560.mbuesch@freenet.de> <41A190D5.5060404@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <41A190D5.5060404@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Michael Buesch <mbuesch@freenet.de>, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 22, 2004 at 06:10:13PM +1100, Nick Piggin wrote:
> Michael Buesch wrote:
> >Hi,
> >
> >I just saw this comment in find_vma():
> >  /* Check the cache first. */
> >  /* (Cache hit rate is typically around 35%.) */
> >
> >I just wanted to play around a bit. Just for fun.
> >So I wrote the attached patch to collect find_vma()
> >statistics. I was wondering why my cache hit rate is around
> >60%. It's always between 55 and 65 percent. Depending on
> >the workload.
> >Is this on obsolete comment from the 2.4 days, maybe?
> >
> >mb@lfs:~$ cat /proc/findvma_stat 
> >findvma_stat_cachehit  == 356524
> >findvma_stat_cachemiss == 248728
> >findvma_stat_fail      == 0
> >cachehit percentage    == 58%
> >cachemiss percentage   == 41%
> >fail percentage        == 0%
> >
> >My kernel is:
> >mb@lfs:~$ uname -r
> >2.6.10-rc2-ck2-nozeroram-findvmastat
> >
> >If you are interrested to comment on this, please CC: me,
> >as I'm not subscribed to this mailing list. Thanks.
> >
> 
> I think the cache hit rate will be pretty variable depending on the
> workload. For example, anything making use of threads, especially on
> an SMP system has the potential to decrease the cache's performance.
> 
> I wouldn't worry too much about the comment - it isn't really
> misleading, at worst inaccurate in a harmless sort of way. Basically
> it is there to say "hey, this really does help", I guess.

BTW, would be interesting to be able to use the PMC (performance counters) 
driver from mikpe to precisely measure cache hit ratio all over the kernel.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
