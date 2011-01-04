Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0838F6B0087
	for <linux-mm@kvack.org>; Tue,  4 Jan 2011 06:43:21 -0500 (EST)
Subject: Re: [Xen-devel] Re: [PATCH 2/3] drivers/xen/balloon.c: Various
 balloon features and fixes
From: Ian Campbell <Ian.Campbell@citrix.com>
In-Reply-To: <20101231112043.GZ2754@reaktio.net>
References: <20101220134724.GC6749@router-fw-old.local.net-space.pl>
	 <20101227150847.GA3728@dumpdata.com>
	 <947c7677e042b3fd1ca22d775ca9aeb9@imap.selfip.ru>
	 <20101227163918.GB7189@dumpdata.com>
	 <92e9dd494cc640c04fdac03fa6d10e8d@imap.selfip.ru>
	 <20101229164910.GD2743@router-fw-old.local.net-space.pl>
	 <20101231112043.GZ2754@reaktio.net>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 4 Jan 2011 11:43:14 +0000
Message-ID: <1294141394.3831.183.camel@zakaz.uk.xensource.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Pasi =?ISO-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>
Cc: Daniel Kiper <dkiper@net-space.pl>, "jeremy@goop.org" <jeremy@goop.org>, "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>, "haicheng.li@linux.intel.com" <haicheng.li@linux.intel.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Vasiliy G Tolstov <v.tolstov@selfip.ru>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "andi.kleen@intel.com" <andi.kleen@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2010-12-31 at 11:20 +0000, Pasi KA?rkkA?inen wrote:
> On Wed, Dec 29, 2010 at 05:49:10PM +0100, Daniel Kiper wrote:
> > Hi,
> > 
> > On Tue, Dec 28, 2010 at 12:52:03AM +0300, Vasiliy G Tolstov wrote:
> > > On Mon, 27 Dec 2010 11:39:18 -0500, Konrad Rzeszutek Wilk
> > > <konrad.wilk@oracle.com> wrote:
> > > > On Mon, Dec 27, 2010 at 07:27:56PM +0300, Vasiliy G Tolstov wrote:
> > > >> On Mon, 27 Dec 2010 10:08:47 -0500, Konrad Rzeszutek Wilk
> > > >> <konrad.wilk@oracle.com> wrote:
> > > >> > On Mon, Dec 20, 2010 at 02:47:24PM +0100, Daniel Kiper wrote:
> > > >> >> Features and fixes:
> > > >> >>   - HVM mode is supported now,
> > > >> >>   - migration from mod_timer() to schedule_delayed_work(),
> > > >> >>   - removal of driver_pages (I do not have seen any
> > > >> >>     references to it),
> > > >> >>   - protect before CPU exhaust by event/x process during
> > > >> >>     errors by adding some delays in scheduling next event,
> > > >> >>   - some other minor fixes.
> > > >>
> > > >> I have apply this patch to bare 2.6.36.2 kernel from kernel.org. If
> > > >> memory=maxmemory pv guest run's on migrating fine.
> > > >> If on already running domU i have xm mem-max xxx 1024 (before that it
> > > >> has 768) and do xm mem-set 1024 guest now have 1024 memory, but after
> > > >> that it can't migrate to another host.
> > 
> > Do you still need memory hotplug patch for jeremy stable-2.6.32.x ???
> > 
> 
> I think it would be good to have it for xen/stable-2.6.32.x aswell!

In general we are hoping to move development of new features to more
recent upstream versions and become increasingly conservative with what
gets taken into the 2.6.32.x branch.

If we think a particular feature is worth having for 2.6.32.x then I
think it would be worth getting them upstream and stabilised before
considering it for backport to 2.6.32.x.

> (that's the tree that's used the most atm).

But what is the demand for this particular functionality among the users
of that tree who cannot or will not switch to a more recent upstream?
Bearing in mind that this is primarily a domU feature and that domU
support is well established upstream.

Ian.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
