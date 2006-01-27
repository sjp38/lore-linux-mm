Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0R0ixQl001781
	for <linux-mm@kvack.org>; Thu, 26 Jan 2006 19:44:59 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0R0lGUO142850
	for <linux-mm@kvack.org>; Thu, 26 Jan 2006 17:47:16 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k0R0ixEa009374
	for <linux-mm@kvack.org>; Thu, 26 Jan 2006 17:44:59 -0700
Message-ID: <43D96D08.6050200@us.ibm.com>
Date: Thu, 26 Jan 2006 16:44:56 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [patch 3/9] mempool - Make mempools NUMA aware
References: <20060125161321.647368000@localhost.localdomain> <1138233093.27293.1.camel@localhost.localdomain> <Pine.LNX.4.62.0601260953200.15128@schroedinger.engr.sgi.com> <43D953C4.5020205@us.ibm.com> <Pine.LNX.4.62.0601261511520.18716@schroedinger.engr.sgi.com> <43D95A2E.4020002@us.ibm.com> <Pine.LNX.4.62.0601261525570.18810@schroedinger.engr.sgi.com> <43D96633.4080900@us.ibm.com> <Pine.LNX.4.62.0601261619030.19029@schroedinger.engr.sgi.com> <43D96A93.9000600@us.ibm.com> <Pine.LNX.4.62.0601261638210.19078@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0601261638210.19078@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-kernel@vger.kernel.org, sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Thu, 26 Jan 2006, Matthew Dobson wrote:
> 
> 
>>That seems a bit beyond the scope of what I'd hoped for this patch series,
>>but if an approach like this is believed to be generally useful, it's
>>something I'm more than willing to work on...
> 
> 
> We need this for other issues as well. f.e. to establish memory allocation 
> policies for the page cache, tmpfs and various other needs. Look at 
> mempolicy.h which defines a subset of what we need. Currently there is no 
> way to specify a policy when invoking the page allocator or slab 
> allocator. The policy is implicily fetched from the current task structure 
> which is not optimal.

I agree that the current, task-based policies are subobtimal.  Having to
allocate and fill in even a small structure for each allocation is going to
be a tough sell, though.  I suppose most allocations could get by with a
small handfull of static generic "policy structures"...  This seems like it
will turn into a signifcant rework of all the kernel's allocation routines,
no small task.  Certainly not something that I'd even start without
response from some other major players in the VM area...  Anyone?


-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
