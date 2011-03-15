Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id ECAA88D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 11:32:21 -0400 (EDT)
Date: Tue, 15 Mar 2011 15:31:47 +0000
From: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Subject: Re: Bootup fix for _brk_end being != _end
In-Reply-To: <20110315153001.GD12730@router-fw-old.local.net-space.pl>
Message-ID: <alpine.DEB.2.00.1103151530290.3382@kaball-desktop>
References: <20110308214429.GA27331@router-fw-old.local.net-space.pl> <alpine.DEB.2.00.1103091359290.2968@kaball-desktop> <20110315142957.GB12730@router-fw-old.local.net-space.pl> <20110315144821.GA11586@dumpdata.com>
 <20110315153001.GD12730@router-fw-old.local.net-space.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Stefano Stabellini <Stefano.Stabellini@eu.citrix.com>, Ian Campbell <Ian.Campbell@eu.citrix.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "andi.kleen@intel.com" <andi.kleen@intel.com>, "haicheng.li@linux.intel.com" <haicheng.li@linux.intel.com>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>, "jeremy@goop.org" <jeremy@goop.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, "v.tolstov@selfip.ru" <v.tolstov@selfip.ru>, "pasik@iki.fi" <pasik@iki.fi>, "dave@linux.vnet.ibm.com" <dave@linux.vnet.ibm.com>, "wdauchy@gmail.com" <wdauchy@gmail.com>, "rientjes@google.com" <rientjes@google.com>, "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 15 Mar 2011, Daniel Kiper wrote:
> On Tue, Mar 15, 2011 at 10:48:21AM -0400, Konrad Rzeszutek Wilk wrote:
> > > > > Additionally, I suggest to apply patch prepared by Steffano Stabellini
> > > > > (https://lkml.org/lkml/2011/1/31/232) which fixes memory management
> > > > > issue in Xen guest. I was not able boot guest machine without
> > > > > above mentioned patch.
> > > >
> > > > after some discussions we came up with a different approach to fix the
> > > > issue; I sent a couple of patches a little while ago:
> > > >
> > > > https://lkml.org/lkml/2011/2/28/410
> > >
> > > I tested git://xenbits.xen.org/people/sstabellini/linux-pvhvm.git 2.6.38-tip-fixes
> > > and it works on x86_64, however, it does not work on i386. Tested as
> > > unprivileged guest on Xen Ver. 4.1.0-rc2-pre. On i386 domain crashes
> > > silently at early boot stage :-(((.
> >
> > Details? Can you provide the 'xenctx' output of where it crashed?
> 
> As I wrote above domain is dying and I am not able to connect to it using
> xenctx after crash :-(((. I do not know how to do that in another way.
> 

try adding:

extra = "loglevel=9 debug earlyprintk=xenboot"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
