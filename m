Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 126096B004D
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 01:09:19 -0400 (EDT)
Received: by wa-out-1112.google.com with SMTP id m16so774869waf.22
        for <linux-mm@kvack.org>; Tue, 07 Jul 2009 22:15:20 -0700 (PDT)
Date: Wed, 8 Jul 2009 13:15:15 +0800
From: Wu Fengguang <fengguang.wu@gmail.com>
Subject: Re: OOM killer in 2.6.31-rc2
Message-ID: <20090708051515.GA17156@localhost>
References: <200907061056.00229.gene.heskett@verizon.net> <200907071057.31152.gene.heskett@verizon.net> <20090708021708.GA10481@localhost> <200907072342.07822.gene.heskett@verizon.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200907072342.07822.gene.heskett@verizon.net>
Sender: owner-linux-mm@kvack.org
To: Gene Heskett <gene.heskett@verizon.net>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>, David Howells <dhowells@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 07, 2009 at 11:42:07PM -0400, Gene Heskett wrote:
> On Tuesday 07 July 2009, Wu Fengguang wrote:
> >On Tue, Jul 07, 2009 at 10:57:30PM +0800, Gene Heskett wrote:
> >> On Tuesday 07 July 2009, Wu Fengguang wrote:
> >> >On Mon, Jul 06, 2009 at 10:56:00AM -0400, Gene Heskett wrote:
> >> >> Greetings all;
> [...]
> >> >
> >> >Normal zone is absent in the above lines.
> >>
> >> Is this a .config issue?
> >
> >At least CONFIG_HIGHMEM64G is not necessary, could try disabling it.
> 
> I have in a rebuild of this 2.6.30.1 kernel, but ISTR I enabled that because 
> it was only using 3G of the 4G of ram in this box, an AMD-64 Phenom, 4 cores, 
> 4G ram.  But I haven't rebooted to it yet.  Next good excuse.  See below... :)

I guess you can only use 3G ram because there is a big memory hole.
Your HighMem zone spanned 951810 pages, 813013 of which is present.
So it's not quite accurate for the OOM message "951810 pages HighMem"
to report the spanned pages.

Your Normal zone has 221994 present pages, while the OOM message shows
"slab:206505", which indicates that the OOM is caused by too much
slab pages(they cannot be allocated from HighMem zone).

I guess your near 800MB slab cache is somehow under scanned.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
