Date: Mon, 24 Sep 2007 12:14:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 4/5] mm: test and set zone reclaim lock before starting
 reclaim
In-Reply-To: <Pine.LNX.4.64.0709241202280.29673@schroedinger.engr.sgi.com>
Message-ID: <alpine.DEB.0.9999.0709241211240.16397@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709212311130.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312160.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312400.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312560.13727@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709241202280.29673@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 24 Sep 2007, Christoph Lameter wrote:

> > +++ b/include/linux/mmzone.h
> > @@ -320,6 +320,10 @@ static inline void zone_set_flag(struct zone *zone, zone_flags_t flag)
> >  {
> >  	set_bit(flag, &zone->flags);
> >  }
> > +static inline int zone_test_and_set_flag(struct zone *zone, zone_flags_t flag)
> > +{
> > +	return test_and_set_bit(flag, &zone->flags);
> > +}
> 
> Missing blank line.
> 

The only blank line for inlined functions added to mmzone.h for zone 
flag support is between the generic flavors that set, test and set, or 
clear the flags and the explicit flavors that test specific bits; so this 
newline behavior is correct as written.

I was hoping to avoid doing things like

	#define ZoneSetReclaimLocked(zone)	zone_set_flag((zone),	\
							ZONE_RECLAIM_LOCKED)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
