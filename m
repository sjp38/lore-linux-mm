Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 298A86B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 15:41:43 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa1so3655807pad.14
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 12:41:42 -0800 (PST)
Received: from mail-pb0-x22e.google.com (mail-pb0-x22e.google.com [2607:f8b0:400e:c01::22e])
        by mx.google.com with ESMTPS id ez5si6324658pab.77.2014.02.07.12.41.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 12:41:41 -0800 (PST)
Received: by mail-pb0-f46.google.com with SMTP id um1so3749044pbc.33
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 12:41:40 -0800 (PST)
Date: Fri, 7 Feb 2014 12:41:38 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH V5] mm readahead: Fix readahead fail for no local
 memory and limit readahead pages
In-Reply-To: <52F4B8A4.70405@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1402071239301.4212@chino.kir.corp.google.com>
References: <1390388025-1418-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <20140206145105.27dec37b16f24e4ac5fd90ce@linux-foundation.org> <alpine.DEB.2.02.1402061456290.31828@chino.kir.corp.google.com> <20140206152219.45c2039e5092c8ea1c31fd38@linux-foundation.org>
 <alpine.DEB.2.02.1402061537180.3441@chino.kir.corp.google.com> <alpine.DEB.2.02.1402061557210.5061@chino.kir.corp.google.com> <52F4B8A4.70405@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, Linus <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 7 Feb 2014, Raghavendra K T wrote:

> So following discussion TODO for my patch is:
> 
> 1) Update the changelog with user visible impact of the patch.
> (Andrew's suggestion)
> 2) Add ACCESS_ONCE to numa_node_id().
> 3) Change the "readahead into remote memory" part of the documentation
> which is misleading.
> 
> ( I feel no need to add numa_mem_id() since we would specifically limit
> the readahead with MAX_REMOTE_READAHEAD in memoryless cpu cases).
> 

I don't understand what you're saying, numa_mem_id() is local memory to 
current's cpu.  When a node consists only of cpus and not memory it is not 
true that all memory is then considered remote, you won't find that in any 
specification that defines memory affinity including the ACPI spec.  I can 
trivially define all cpus on my system to be on memoryless nodes and 
having that affect readahead behavior when, in fact, there is affinity 
would be ridiculous.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
