Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id B1AD46B0011
	for <linux-mm@kvack.org>; Thu, 19 May 2011 19:25:54 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1584710Ab1ESXZU (ORCPT <rfc822;linux-mm@kvack.org>);
	Fri, 20 May 2011 01:25:20 +0200
Date: Fri, 20 May 2011 01:25:20 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: Re: [PATCH V3 2/2] mm: Extend memory hotplug API to allow memory hotplug in virtual machines
Message-ID: <20110519232520.GB28832@router-fw-old.local.net-space.pl>
References: <20110517213858.GC30232@router-fw-old.local.net-space.pl> <alpine.DEB.2.00.1105182026390.20651@chino.kir.corp.google.com> <20110519204509.GD27202@router-fw-old.local.net-space.pl> <20110519160143.02163f36.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110519160143.02163f36.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daniel Kiper <dkiper@net-space.pl>, David Rientjes <rientjes@google.com>, ian.campbell@citrix.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, May 19, 2011 at 04:01:43PM -0700, Andrew Morton wrote:
> On Thu, 19 May 2011 22:45:09 +0200
> Daniel Kiper <dkiper@net-space.pl> wrote:
>
> > On Wed, May 18, 2011 at 08:36:02PM -0700, David Rientjes wrote:
> > > On Tue, 17 May 2011, Daniel Kiper wrote:
> > >
> > > > This patch contains online_page_callback and apropriate functions for
> > > > setting/restoring online page callbacks. It allows to do some machine
> > > > specific tasks during online page stage which is required to implement
> > > > memory hotplug in virtual machines. Additionally, __online_page_set_limits(),
> > > > __online_page_increment_counters() and __online_page_free() function
> > > > was added to ease generic hotplug operation.
> > >
> > > There are several issues with this.
> > >
> > > First, this is completely racy and only allows one global callback to be
> > > in use at a time without looping, which is probably why you had to pass an
> >
> > One callback is allowed by design. Currently I do not see
> > any real usage for more than one callback.
>
> I'd suggest that you try using the notifier.h tools here and remove the
> restriction.  Sure, we may never use the capability but I expect the
> code will look nice and simple and once it's done, it's done.

Hmmm... I am a bit confused. Here https://lkml.org/lkml/2011/3/28/510 you
was against (ab)using notifiers. Here https://lkml.org/lkml/2011/3/29/313
you proposed currently implemented solution. Maybe I missed something...
What should I do now ??? I agree that the code should look nice and simple
and once it's done, it's done.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
