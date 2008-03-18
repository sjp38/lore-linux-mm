Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2IHA6Qf023151
	for <linux-mm@kvack.org>; Tue, 18 Mar 2008 13:10:06 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2IHBJVZ184572
	for <linux-mm@kvack.org>; Tue, 18 Mar 2008 11:11:19 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2IHBIlu012611
	for <linux-mm@kvack.org>; Tue, 18 Mar 2008 11:11:19 -0600
Subject: Re: [RFC][2/3] Account and control virtual address space
	allocations
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <47DF1760.9030908@linux.vnet.ibm.com>
References: <20080316172942.8812.56051.sendpatchset@localhost.localdomain>
	 <20080316173005.8812.88290.sendpatchset@localhost.localdomain>
	 <1205772790.18916.17.camel@nimitz.home.sr71.net>
	 <47DF1760.9030908@linux.vnet.ibm.com>
Content-Type: text/plain
Date: Tue, 18 Mar 2008 10:11:16 -0700
Message-Id: <1205860276.8872.20.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-03-18 at 06:44 +0530, Balbir Singh wrote: 
> > If you're going to do this, I think you need a couple of phases.  
> > 
> > 1. update the vm_(un)acct_memory() functions to take an mm
> 
> There are other problems
> 
> 1. vm_(un)acct_memory is conditionally dependent on VM_ACCOUNT. Look at
> shmem_(un)acct_size for example

Yeah, but if VM_ACCOUNT isn't set, do you really want the controller
accounting for them?  It's there for a reason. :)

The shmem_acct_size() helpers look good.  I wonder if we should be using
that kind of things more generically.

> 2. These routines are not called from all contexts that we care about (look at
> insert_special_mapping())

Could you explain why "we" care about it and why it isn't accounted for
now?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
