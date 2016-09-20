Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8ACAD6B0038
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 20:54:30 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id mi5so4737664pab.2
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 17:54:30 -0700 (PDT)
Received: from mail-pf0-x232.google.com (mail-pf0-x232.google.com. [2607:f8b0:400e:c00::232])
        by mx.google.com with ESMTPS id v20si17484024pfi.178.2016.09.19.17.54.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Sep 2016 17:54:29 -0700 (PDT)
Received: by mail-pf0-x232.google.com with SMTP id q2so824284pfj.3
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 17:54:28 -0700 (PDT)
Date: Mon, 19 Sep 2016 17:54:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH V4] mm: Add sysfs interface to dump each node's zonelist
 information
In-Reply-To: <57DCC605.10305@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1609191752080.53329@chino.kir.corp.google.com>
References: <1473150666-3875-1-git-send-email-khandual@linux.vnet.ibm.com> <1473302818-23974-1-git-send-email-khandual@linux.vnet.ibm.com> <57D1C914.9090403@intel.com> <57D63CB2.8070003@linux.vnet.ibm.com> <alpine.DEB.2.10.1609121106500.39030@chino.kir.corp.google.com>
 <57DCC605.10305@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On Sat, 17 Sep 2016, Anshuman Khandual wrote:

> > I'm questioning if this information can be inferred from information 
> > already in /proc/zoneinfo and sysfs.  We know the no-fallback zonelist is 
> > going to include the local node, and we know the other zonelists are 
> > either node ordered or zone ordered (or do we need to extend 
> > vm.numa_zonelist_order for default?).  I may have missed what new 
> > knowledge this interface is imparting on us.
> 
> IIUC /proc/zoneinfo lists down zone internal state and statistics for
> all zones on the system at any given point of time. The no-fallback
> list contains the zones from the local node and fallback (which gets
> used more often than the no-fallback) list contains all zones either
> in node-ordered or zone-ordered manner. In most of the platforms the
> default being the node order but the sequence of present nodes in
> that order is determined by various factors like NUMA distance, load,
> presence of CPUs on the node etc. This order of nodes in the fallback
> list is the most important information derived out of this interface.
> 

The point is that all of this can be inferred with information already 
provided, so the additional interface seems unnecessary.  The only 
extension I think that is needed is to determine if the order is node or 
zone when vm.numa_zonelist_order == default and we shouldn't parse this 
from dmesg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
