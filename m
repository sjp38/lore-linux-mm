Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0QN1p0Y003948
	for <linux-mm@kvack.org>; Thu, 26 Jan 2006 18:01:51 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0QN48UO132410
	for <linux-mm@kvack.org>; Thu, 26 Jan 2006 16:04:08 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k0QN1pH7013729
	for <linux-mm@kvack.org>; Thu, 26 Jan 2006 16:01:51 -0700
Message-ID: <43D954D8.2050305@us.ibm.com>
Date: Thu, 26 Jan 2006 15:01:44 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [patch 0/9] Critical Mempools
References: <1138217992.2092.0.camel@localhost.localdomain> <Pine.LNX.4.62.0601260954540.15128@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0601260954540.15128@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-kernel@vger.kernel.org, sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Wed, 25 Jan 2006, Matthew Dobson wrote:
> 
> 
>>Using this new approach, a subsystem can create a mempool and then pass a
>>pointer to this mempool on to all its slab allocations.  Anytime one of its
>>slab allocations needs to allocate memory that memory will be allocated
>>through the specified mempool, rather than through alloc_pages_node() directly.
> 
> 
> All subsystems will now get more complicated by having to add this 
> emergency functionality?

Certainly not.  Only subsystems that want to use emergency pools will get
more complicated.  If you have a suggestion as to how to implement a
similar feature that is completely transparent to its users, I would *love*
to hear it.  I have tried to keep the changes to implement this
functionality to a minimum.  As the patches currently stand, existing slab
allocator and mempool users can continue using these subsystems without
modification.


>>Feedback on these patches (against 2.6.16-rc1) would be greatly appreciated.
> 
> 
> There surely must be a better way than revising all subsystems for 
> critical allocations.

Again, I could not find any way to implement this functionality without
forcing the users of the functionality to make some, albeit very minor,
changes.  Specific suggestions are more than welcome! :)

Thanks!

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
