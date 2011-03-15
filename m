Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 761E08D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 10:30:18 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1556207Ab1COO35 (ORCPT <rfc822;linux-mm@kvack.org>);
	Tue, 15 Mar 2011 15:29:57 +0100
Date: Tue, 15 Mar 2011 15:29:57 +0100
From: Daniel Kiper <dkiper@net-space.pl>
Subject: Re: [PATCH R4 0/7] xen/balloon: Memory hotplug support for Xen balloon driver
Message-ID: <20110315142957.GB12730@router-fw-old.local.net-space.pl>
References: <20110308214429.GA27331@router-fw-old.local.net-space.pl> <alpine.DEB.2.00.1103091359290.2968@kaball-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1103091359290.2968@kaball-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Cc: Daniel Kiper <dkiper@net-space.pl>, Ian Campbell <Ian.Campbell@eu.citrix.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "andi.kleen@intel.com" <andi.kleen@intel.com>, "haicheng.li@linux.intel.com" <haicheng.li@linux.intel.com>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>, "jeremy@goop.org" <jeremy@goop.org>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, "v.tolstov@selfip.ru" <v.tolstov@selfip.ru>, "pasik@iki.fi" <pasik@iki.fi>, "dave@linux.vnet.ibm.com" <dave@linux.vnet.ibm.com>, "wdauchy@gmail.com" <wdauchy@gmail.com>, "rientjes@google.com" <rientjes@google.com>, "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Mar 09, 2011 at 02:01:25PM +0000, Stefano Stabellini wrote:
> On Tue, 8 Mar 2011, Daniel Kiper wrote:
> > Hi,
> >
> > I am sending next version of memory hotplug
> > support for Xen balloon driver patch. It applies
> > to Linus' git tree, v2.6.38-rc8 tag. Most of
> > suggestions were taken into account. Thanks for
> > everybody who tested and/or sent suggestions
> > to my work.
> >
> > There are a few prerequisite patches which fixes
> > some problems found during work on memory hotplug
> > patch or add some futures which are needed by
> > memory hotplug patch.
> >
> > Full list of fixes/futures:
> >   - xen/balloon: Removal of driver_pages,
> >   - xen/balloon: HVM mode support,
> >   - xen/balloon: Migration from mod_timer() to schedule_delayed_work(),
> >   - xen/balloon: Protect against CPU exhaust by event/x process,
> >   - xen/balloon: Minor notation fixes,
> >   - mm: Extend memory hotplug API to allow memory hotplug in virtual guests,
> >   - xen/balloon: Memory hotplug support for Xen balloon driver.
> >
> > Additionally, I suggest to apply patch prepared by Steffano Stabellini
> > (https://lkml.org/lkml/2011/1/31/232) which fixes memory management
> > issue in Xen guest. I was not able boot guest machine without
> > above mentioned patch.
>
> after some discussions we came up with a different approach to fix the
> issue; I sent a couple of patches a little while ago:
>
> https://lkml.org/lkml/2011/2/28/410

I tested git://xenbits.xen.org/people/sstabellini/linux-pvhvm.git 2.6.38-tip-fixes
and it works on x86_64, however, it does not work on i386. Tested as
unprivileged guest on Xen Ver. 4.1.0-rc2-pre. On i386 domain crashes
silently at early boot stage :-(((.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
