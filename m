Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CE770900001
	for <linux-mm@kvack.org>; Thu, 12 May 2011 15:26:37 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p4CJQQwl003668
	for <linux-mm@kvack.org>; Thu, 12 May 2011 12:26:26 -0700
Received: from pzk35 (pzk35.prod.google.com [10.243.19.163])
	by wpaz5.hot.corp.google.com with ESMTP id p4CJPuWe007493
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 12 May 2011 12:26:24 -0700
Received: by pzk35 with SMTP id 35so1237759pzk.11
        for <linux-mm@kvack.org>; Thu, 12 May 2011 12:26:24 -0700 (PDT)
Date: Thu, 12 May 2011 12:26:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/4] mm: Remove dependency on CONFIG_FLATMEM from
 online_page()
In-Reply-To: <20110512102515.GA27851@router-fw-old.local.net-space.pl>
Message-ID: <alpine.DEB.2.00.1105121223500.2407@chino.kir.corp.google.com>
References: <20110502211915.GB4623@router-fw-old.local.net-space.pl> <alpine.DEB.2.00.1105111547160.24003@chino.kir.corp.google.com> <20110512102515.GA27851@router-fw-old.local.net-space.pl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 12 May 2011, Daniel Kiper wrote:

> > > Memory hotplug code strictly depends on CONFIG_SPARSEMEM.
> > > It means that code depending on CONFIG_FLATMEM in online_page()
> > > is never compiled. Remove it because it is not needed anymore.
> > >
> > > Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
> >
> > The code you're patching depends on CONFIG_MEMORY_HOTPLUG_SPARSE, so this
> > is valid.  The changelog should be updated to reflect that, however.
> >
> > Acked-by: David Rientjes <rientjes@google.com>
> 
> No problem, however, this bundle of patches was added to the -mm tree.
> In this situation should I repost whole bundle with relevant changes
> or post only those two patches requested by you ??? For which tree
> should I prepare new version of patches ???
> 

No, I would just reply to the email notification you received when the 
patch went into -mm saying that the changelog should be adjusted to read 
something like

	online_pages() is only compiled for CONFIG_MEMORY_HOTPLUG_SPARSE,
	so there is no need to support CONFIG_FLATMEM code within it.

	This patch removes code that is never used.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
