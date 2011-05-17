Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BFA556B0012
	for <linux-mm@kvack.org>; Tue, 17 May 2011 04:47:56 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1573791Ab1EQIqH (ORCPT <rfc822;linux-mm@kvack.org>);
	Tue, 17 May 2011 10:46:07 +0200
Date: Tue, 17 May 2011 10:46:06 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: Re: [PATCH 1/4] mm: Remove dependency on CONFIG_FLATMEM from online_page()
Message-ID: <20110517084606.GA21622@router-fw-old.local.net-space.pl>
References: <20110502211915.GB4623@router-fw-old.local.net-space.pl> <alpine.DEB.2.00.1105111547160.24003@chino.kir.corp.google.com> <20110512102515.GA27851@router-fw-old.local.net-space.pl> <alpine.DEB.2.00.1105121223500.2407@chino.kir.corp.google.com> <20110516075849.GB6393@router-fw-old.local.net-space.pl> <alpine.DEB.2.00.1105161330570.4353@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1105161330570.4353@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Daniel Kiper <dkiper@net-space.pl>, ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, May 16, 2011 at 01:32:19PM -0700, David Rientjes wrote:
> On Mon, 16 May 2011, Daniel Kiper wrote:
>
> > > No, I would just reply to the email notification you received when the
> > > patch went into -mm saying that the changelog should be adjusted to read
> > > something like
> > >
> > > 	online_pages() is only compiled for CONFIG_MEMORY_HOTPLUG_SPARSE,
> > > 	so there is no need to support CONFIG_FLATMEM code within it.
> > >
> > > 	This patch removes code that is never used.
> >
> > Please look into attachments.
> >
> > If you have any questions please drop me a line.
>
> Not sure why you've attached the emails from the mm-commits mailing list.

I attached emails from the mm-commits mailing list because
I understood that you need them to correct changelogs.

> I'll respond to the commits with with my suggestions for how the changelog
> should be fixed.

I saw your replies. Thank you for your help.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
