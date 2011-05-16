Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0CA286B0022
	for <linux-mm@kvack.org>; Mon, 16 May 2011 03:59:40 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1544372Ab1EPH6t (ORCPT <rfc822;linux-mm@kvack.org>);
	Mon, 16 May 2011 09:58:49 +0200
Date: Mon, 16 May 2011 09:58:49 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: Re: [PATCH 1/4] mm: Remove dependency on CONFIG_FLATMEM from online_page()
Message-ID: <20110516075849.GB6393@router-fw-old.local.net-space.pl>
References: <20110502211915.GB4623@router-fw-old.local.net-space.pl> <alpine.DEB.2.00.1105111547160.24003@chino.kir.corp.google.com> <20110512102515.GA27851@router-fw-old.local.net-space.pl> <alpine.DEB.2.00.1105121223500.2407@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="HlL+5n6rz5pIUxbD"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1105121223500.2407@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Daniel Kiper <dkiper@net-space.pl>, ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org


--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, May 12, 2011 at 12:26:22PM -0700, David Rientjes wrote:
> On Thu, 12 May 2011, Daniel Kiper wrote:
>
> > > > Memory hotplug code strictly depends on CONFIG_SPARSEMEM.
> > > > It means that code depending on CONFIG_FLATMEM in online_page()
> > > > is never compiled. Remove it because it is not needed anymore.
> > > >
> > > > Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
> > >
> > > The code you're patching depends on CONFIG_MEMORY_HOTPLUG_SPARSE, so this
> > > is valid.  The changelog should be updated to reflect that, however.
> > >
> > > Acked-by: David Rientjes <rientjes@google.com>
> >
> > No problem, however, this bundle of patches was added to the -mm tree.
> > In this situation should I repost whole bundle with relevant changes
> > or post only those two patches requested by you ??? For which tree
> > should I prepare new version of patches ???
> >
>
> No, I would just reply to the email notification you received when the
> patch went into -mm saying that the changelog should be adjusted to read
> something like
>
> 	online_pages() is only compiled for CONFIG_MEMORY_HOTPLUG_SPARSE,
> 	so there is no need to support CONFIG_FLATMEM code within it.
>
> 	This patch removes code that is never used.

Please look into attachments.

If you have any questions please drop me a line.

Daniel

--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="mm-enable-set_page_section-only-if-config_sparsemem-and-config_sparsemem_vmemmap.patch"


--HlL+5n6rz5pIUxbD--
