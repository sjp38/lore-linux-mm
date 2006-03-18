From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH][RFC] mm: swsusp shrink_all_memory tweaks
Date: Sat, 18 Mar 2006 15:46:19 +1100
References: <200603101704.AA00798@bbb-jz5c7z9hn9y.digitalinfra.co.jp> <200603181514.27455.kernel@kolivas.org> <441B8F6E.7010802@yahoo.com.au>
In-Reply-To: <441B8F6E.7010802@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200603181546.20794.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, ck@vds.kolivas.org, Andreas Mohr <andi@rhlx01.fht-esslingen.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pavel Machek <pavel@suse.cz>, Stefan Seyfried <seife@suse.de>
List-ID: <linux-mm.kvack.org>

On Saturday 18 March 2006 15:41, Nick Piggin wrote:
> Con Kolivas wrote:
> > @@ -1567,7 +1546,7 @@ loop_again:
> >  		zone->temp_priority = DEF_PRIORITY;
> >  	}
> >
> > -	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
> > +	for_each_priority_reverse(priority) {
>
> What's this for? The for loop is simple and easy to read, after
> the change, you have to look somewhere else to see what it does.

Saw the same for loop 3 times and couldn't resist.

> > Index: linux-2.6.16-rc6-mm1/include/linux/swap.h
> > ===================================================================
> > --- linux-2.6.16-rc6-mm1.orig/include/linux/swap.h	2006-03-18
> > 13:29:38.000000000 +1100 +++
> > linux-2.6.16-rc6-mm1/include/linux/swap.h	2006-03-18 14:50:11.000000000
> > +1100 @@ -66,6 +66,51 @@ typedef struct {
> >  	unsigned long val;
> >  } swp_entry_t;
> >
> > +struct scan_control {
>
> Why did you put this here? scan_control really can't go outside vmscan.c,
> it is meant only to ease the passing of lots of parameters, and not as a
> consistent interface.

#ifdeffery

Cheers,
Con

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
