Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 226AF90010B
	for <linux-mm@kvack.org>; Mon, 16 May 2011 16:32:27 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p4GKWNID026297
	for <linux-mm@kvack.org>; Mon, 16 May 2011 13:32:23 -0700
Received: from pzk5 (pzk5.prod.google.com [10.243.19.133])
	by wpaz17.hot.corp.google.com with ESMTP id p4GKWLrv017414
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 16 May 2011 13:32:22 -0700
Received: by pzk5 with SMTP id 5so3649076pzk.17
        for <linux-mm@kvack.org>; Mon, 16 May 2011 13:32:21 -0700 (PDT)
Date: Mon, 16 May 2011 13:32:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/4] mm: Remove dependency on CONFIG_FLATMEM from
 online_page()
In-Reply-To: <20110516075849.GB6393@router-fw-old.local.net-space.pl>
Message-ID: <alpine.DEB.2.00.1105161330570.4353@chino.kir.corp.google.com>
References: <20110502211915.GB4623@router-fw-old.local.net-space.pl> <alpine.DEB.2.00.1105111547160.24003@chino.kir.corp.google.com> <20110512102515.GA27851@router-fw-old.local.net-space.pl> <alpine.DEB.2.00.1105121223500.2407@chino.kir.corp.google.com>
 <20110516075849.GB6393@router-fw-old.local.net-space.pl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 16 May 2011, Daniel Kiper wrote:

> > No, I would just reply to the email notification you received when the
> > patch went into -mm saying that the changelog should be adjusted to read
> > something like
> >
> > 	online_pages() is only compiled for CONFIG_MEMORY_HOTPLUG_SPARSE,
> > 	so there is no need to support CONFIG_FLATMEM code within it.
> >
> > 	This patch removes code that is never used.
> 
> Please look into attachments.
> 
> If you have any questions please drop me a line.
> 

Not sure why you've attached the emails from the mm-commits mailing list.  
I'll respond to the commits with with my suggestions for how the changelog 
should be fixed.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
