Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 73F558D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 17:13:27 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p2TLBvoJ000679
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 14:11:57 -0700
Received: from pvf33 (pvf33.prod.google.com [10.241.210.97])
	by wpaz9.hot.corp.google.com with ESMTP id p2TLBcwB003843
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 14:11:56 -0700
Received: by pvf33 with SMTP id 33so106574pvf.38
        for <linux-mm@kvack.org>; Tue, 29 Mar 2011 14:11:55 -0700 (PDT)
Date: Tue, 29 Mar 2011 14:11:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] mm: Add SECTION_ALIGN_UP() and SECTION_ALIGN_DOWN()
 macro
In-Reply-To: <20110329173221.GB30387@router-fw-old.local.net-space.pl>
Message-ID: <alpine.DEB.2.00.1103291408150.1844@chino.kir.corp.google.com>
References: <20110328092412.GC13826@router-fw-old.local.net-space.pl> <alpine.DEB.2.00.1103281545220.7148@chino.kir.corp.google.com> <20110329173221.GB30387@router-fw-old.local.net-space.pl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 29 Mar 2011, Daniel Kiper wrote:

> > These are only valid for CONFIG_SPARSEMEM, so they need to be defined 
> > conditionally.
> 
> OK, however, I think that pfn_to_section_nr()/section_nr_to_pfn()
> should be defined conditionally, too.
> 

Yes, and you could try removing this from include/linux/mm.h:

#ifndef PFN_SECTION_SHIFT
#define PFN_SECTION_SHIFT 0 
#endif

then we'll reveal anything using these conversion macros that don't rely 
on sparsemem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
