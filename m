Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 289D08D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 10:15:39 -0500 (EST)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1574992Ab1BCPOu (ORCPT <rfc822;linux-mm@kvack.org>);
	Thu, 3 Feb 2011 16:14:50 +0100
Date: Thu, 3 Feb 2011 16:14:50 +0100
From: Daniel Kiper <dkiper@net-space.pl>
Subject: Re: [Xen-devel] Re: [PATCH 2/3] drivers/xen/balloon.c: Various balloon features and fixes
Message-ID: <20110203151450.GA1364@router-fw-old.local.net-space.pl>
References: <20101220134724.GC6749@router-fw-old.local.net-space.pl> <20101227150847.GA3728@dumpdata.com> <947c7677e042b3fd1ca22d775ca9aeb9@imap.selfip.ru> <20101227163918.GB7189@dumpdata.com> <92e9dd494cc640c04fdac03fa6d10e8d@imap.selfip.ru> <20101229164910.GD2743@router-fw-old.local.net-space.pl> <20101231112043.GZ2754@reaktio.net> <1294141394.3831.183.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1294141394.3831.183.camel@zakaz.uk.xensource.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Cc: Pasi K?rkk?inen <pasik@iki.fi>, Daniel Kiper <dkiper@net-space.pl>, "jeremy@goop.org" <jeremy@goop.org>, "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>, "haicheng.li@linux.intel.com" <haicheng.li@linux.intel.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Vasiliy G Tolstov <v.tolstov@selfip.ru>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "andi.kleen@intel.com" <andi.kleen@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>

On Tue, Jan 04, 2011 at 11:43:14AM +0000, Ian Campbell wrote:
> On Fri, 2010-12-31 at 11:20 +0000, Pasi K??rkk??inen wrote:
> > On Wed, Dec 29, 2010 at 05:49:10PM +0100, Daniel Kiper wrote:
> > > Hi,
> > >
> > > On Tue, Dec 28, 2010 at 12:52:03AM +0300, Vasiliy G Tolstov wrote:
> > > > On Mon, 27 Dec 2010 11:39:18 -0500, Konrad Rzeszutek Wilk
> > > > <konrad.wilk@oracle.com> wrote:
> > > > > On Mon, Dec 27, 2010 at 07:27:56PM +0300, Vasiliy G Tolstov wrote:
> > > > >> On Mon, 27 Dec 2010 10:08:47 -0500, Konrad Rzeszutek Wilk
> > > > >> <konrad.wilk@oracle.com> wrote:
> > > > >> > On Mon, Dec 20, 2010 at 02:47:24PM +0100, Daniel Kiper wrote:
> > > > >> >> Features and fixes:
> > > > >> >>   - HVM mode is supported now,
> > > > >> >>   - migration from mod_timer() to schedule_delayed_work(),
> > > > >> >>   - removal of driver_pages (I do not have seen any
> > > > >> >>     references to it),
> > > > >> >>   - protect before CPU exhaust by event/x process during
> > > > >> >>     errors by adding some delays in scheduling next event,
> > > > >> >>   - some other minor fixes.
> > > > >>
> > > > >> I have apply this patch to bare 2.6.36.2 kernel from kernel.org. If
> > > > >> memory=maxmemory pv guest run's on migrating fine.
> > > > >> If on already running domU i have xm mem-max xxx 1024 (before that it
> > > > >> has 768) and do xm mem-set 1024 guest now have 1024 memory, but after
> > > > >> that it can't migrate to another host.
> > >
> > > Do you still need memory hotplug patch for jeremy stable-2.6.32.x ???
> >
> > I think it would be good to have it for xen/stable-2.6.32.x aswell!
>
> In general we are hoping to move development of new features to more
> recent upstream versions and become increasingly conservative with what
> gets taken into the 2.6.32.x branch.
>
> If we think a particular feature is worth having for 2.6.32.x then I
> think it would be worth getting them upstream and stabilised before
> considering it for backport to 2.6.32.x.
>
> > (that's the tree that's used the most atm).
>
> But what is the demand for this particular functionality among the users
> of that tree who cannot or will not switch to a more recent upstream?
> Bearing in mind that this is primarily a domU feature and that domU
> support is well established upstream.

I agree with Ian. However, I think that if it will be expected
by community I could prepare backport of final upstream version
and publish it as "unofficial" version.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
