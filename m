Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5B7936B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 14:13:47 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ag5so356365016pad.2
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 11:13:47 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id rx5si22684973pac.54.2016.09.12.11.13.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 11:13:46 -0700 (PDT)
Received: by mail-pa0-x233.google.com with SMTP id b2so53079544pat.2
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 11:13:45 -0700 (PDT)
Date: Mon, 12 Sep 2016 11:13:43 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH V4] mm: Add sysfs interface to dump each node's zonelist
 information
In-Reply-To: <57D63CB2.8070003@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1609121106500.39030@chino.kir.corp.google.com>
References: <1473150666-3875-1-git-send-email-khandual@linux.vnet.ibm.com> <1473302818-23974-1-git-send-email-khandual@linux.vnet.ibm.com> <57D1C914.9090403@intel.com> <57D63CB2.8070003@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On Mon, 12 Sep 2016, Anshuman Khandual wrote:

> >> > after memory or node hot[un]plug is desirable. This change adds one
> >> > new sysfs interface (/sys/devices/system/memory/system_zone_details)
> >> > which will fetch and dump this information.
> > Doesn't this violate the "one value per file" sysfs rule?  Does it
> > belong in debugfs instead?
> 
> Yeah sure. Will make it a debugfs interface.
> 

So the intended reader of this file is running as root?

> > I also really question the need to dump kernel addresses out, filtered 
> > or not.  What's the point?
> 
> Hmm, thought it to be an additional information. But yes its additional
> and can be dropped.
> 

I'm questioning if this information can be inferred from information 
already in /proc/zoneinfo and sysfs.  We know the no-fallback zonelist is 
going to include the local node, and we know the other zonelists are 
either node ordered or zone ordered (or do we need to extend 
vm.numa_zonelist_order for default?).  I may have missed what new 
knowledge this interface is imparting on us.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
