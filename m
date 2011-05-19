Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9406C6B0011
	for <linux-mm@kvack.org>; Wed, 18 May 2011 23:09:29 -0400 (EDT)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id p4J39MUY025257
	for <linux-mm@kvack.org>; Wed, 18 May 2011 20:09:26 -0700
Received: from pwi8 (pwi8.prod.google.com [10.241.219.8])
	by kpbe15.cbf.corp.google.com with ESMTP id p4J39KNs024609
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 18 May 2011 20:09:21 -0700
Received: by pwi8 with SMTP id 8so1221118pwi.36
        for <linux-mm@kvack.org>; Wed, 18 May 2011 20:09:20 -0700 (PDT)
Date: Wed, 18 May 2011 20:09:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH V3 0/2] mm: Memory hotplug interface changes
In-Reply-To: <20110518151131.GB4709@dumpdata.com>
Message-ID: <alpine.DEB.2.00.1105182008160.20651@chino.kir.corp.google.com>
References: <20110517213604.GA30232@router-fw-old.local.net-space.pl> <20110518151131.GB4709@dumpdata.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Daniel Kiper <dkiper@net-space.pl>, ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 18 May 2011, Konrad Rzeszutek Wilk wrote:

> > Full list of futures:
> >   - mm: Add SECTION_ALIGN_UP() and SECTION_ALIGN_DOWN() macro,
> >   - mm: Extend memory hotplug API to allow memory hotplug in virtual
> >     machines.
> > 
> > Those patches applies to Linus' git tree, v2.6.39-rc7 tag with a few
> > prerequisite patches available at https://lkml.org/lkml/2011/5/2/296.
> 
> Are they in akpm tree?
> 
> Dave and David, you guys Acked them - are they suppose to go through your
> tree(s) or Andrew's?
> 

All of the prerequisite patches are in mmotm-2011-05-12-15-52 already.  
See http://userweb.kernel.org/~akpm/mmotm/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
