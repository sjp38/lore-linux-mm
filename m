From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH][RFC] mm: swsusp shrink_all_memory tweaks
Date: Sat, 18 Mar 2006 15:56:22 +1100
References: <200603101704.AA00798@bbb-jz5c7z9hn9y.digitalinfra.co.jp> <200603181546.20794.kernel@kolivas.org> <441B9205.5010701@yahoo.com.au>
In-Reply-To: <441B9205.5010701@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200603181556.23307.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, ck@vds.kolivas.org, Andreas Mohr <andi@rhlx01.fht-esslingen.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pavel Machek <pavel@suse.cz>, Stefan Seyfried <seife@suse.de>
List-ID: <linux-mm.kvack.org>

On Saturday 18 March 2006 15:52, Nick Piggin wrote:
> Con Kolivas wrote:
> > On Saturday 18 March 2006 15:41, Nick Piggin wrote:
> >>>Index: linux-2.6.16-rc6-mm1/include/linux/swap.h
> >>>===================================================================
> >>>--- linux-2.6.16-rc6-mm1.orig/include/linux/swap.h	2006-03-18
> >>>13:29:38.000000000 +1100 +++
> >>>linux-2.6.16-rc6-mm1/include/linux/swap.h	2006-03-18 14:50:11.000000000
> >>>+1100 @@ -66,6 +66,51 @@ typedef struct {
> >>> 	unsigned long val;
> >>> } swp_entry_t;
> >>>
> >>>+struct scan_control {
> >>
> >>Why did you put this here? scan_control really can't go outside vmscan.c,
> >>it is meant only to ease the passing of lots of parameters, and not as a
> >>consistent interface.
> >
> > #ifdeffery
>
> Sorry I don't understand...

My bad.

I added the suspend_pass member to struct scan_control within an #ifdef 
CONFIG_PM to allow it to not be unnecessarily compiled in in the !CONFIG_PM 
case and wanted to avoid having the #ifdefs in vmscan.c so moved it to a 
header file.

Cheers,
Con

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
