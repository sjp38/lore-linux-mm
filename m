Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 427356B0088
	for <linux-mm@kvack.org>; Wed, 29 Dec 2010 10:02:02 -0500 (EST)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1564440Ab0L2PB0 (ORCPT <rfc822;linux-mm@kvack.org>);
	Wed, 29 Dec 2010 16:01:26 +0100
Date: Wed, 29 Dec 2010 16:01:26 +0100
From: Daniel Kiper <dkiper@net-space.pl>
Subject: Re: [Xen-devel] [PATCH 2/3] drivers/xen/balloon.c: Various balloon features and fixes
Message-ID: <20101229150126.GA2743@router-fw-old.local.net-space.pl>
References: <20101220134724.GC6749@router-fw-old.local.net-space.pl> <1292856704.4500.249.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1292856704.4500.249.camel@zakaz.uk.xensource.com>
Sender: owner-linux-mm@kvack.org
To: Ian Campbell <Ian.Campbell@citrix.com>
Cc: Daniel Kiper <dkiper@net-space.pl>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "andi.kleen@intel.com" <andi.kleen@intel.com>, "haicheng.li@linux.intel.com" <haicheng.li@linux.intel.com>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>, "jeremy@goop.org" <jeremy@goop.org>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, "v.tolstov@selfip.ru" <v.tolstov@selfip.ru>, "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Dec 20, 2010 at 02:51:44PM +0000, Ian Campbell wrote:
> On Mon, 2010-12-20 at 13:47 +0000, Daniel Kiper wrote:
> > Features and fixes:
> >   - HVM mode is supported now,
> >   - migration from mod_timer() to schedule_delayed_work(),
> >   - removal of driver_pages (I do not have seen any
> >     references to it),
> >   - protect before CPU exhaust by event/x process during
> >     errors by adding some delays in scheduling next event,
> >   - some other minor fixes.
>
> Each of those bullets should be a separate patch (or several if
> appropriate). I didn't review most of the rest because it mixed so much
> stuff together but a couple of minor things jumped out.

Done. I will send new patch release today.

> > -static void scrub_page(struct page *page)
> > +static inline void scrub_page(struct page *page)
>
> Is there some reason we need to override the compiler's decision here?
> There is some discussion of the (over)use of inline in CodingStyle.

Done.

> >  static struct attribute_group balloon_info_group = {
> >         .name = "info",
> > -       .attrs = balloon_info_attrs,
> > +       .attrs = balloon_info_attrs
> >  };
> >
> >  static struct sysdev_class balloon_sysdev_class = {
> > -       .name = BALLOON_CLASS_NAME,
> > +       .name = BALLOON_CLASS_NAME
> >  };
>
> I don't think there is anything wrong with the existing style here.

I do not insist on applying this patch however, this notation
is more readable for me. I am not confused by
comma which suggest that next attribut follow it.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
