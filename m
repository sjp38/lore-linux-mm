Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jBEGQCgS005212
	for <linux-mm@kvack.org>; Wed, 14 Dec 2005 11:26:12 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jBEGPLp9122842
	for <linux-mm@kvack.org>; Wed, 14 Dec 2005 09:25:21 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jBEGQCkx001014
	for <linux-mm@kvack.org>; Wed, 14 Dec 2005 09:26:12 -0700
Message-ID: <43A047A1.9030308@us.ibm.com>
Date: Wed, 14 Dec 2005 08:26:09 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/6] Create Critical Page Pool
References: <439FCECA.3060909@us.ibm.com> <439FCF4E.3090202@us.ibm.com> <Pine.LNX.4.63.0512140829410.2723@cuia.boston.redhat.com>
In-Reply-To: <Pine.LNX.4.63.0512140829410.2723@cuia.boston.redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, andrea@suse.de, Sridhar Samudrala <sri@us.ibm.com>, pavel@suse.cz, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> On Tue, 13 Dec 2005, Matthew Dobson wrote:
> 
> 
>>Create the basic Critical Page Pool.  Any allocation specifying 
>>__GFP_CRITICAL will, as a last resort before failing the allocation, try 
>>to get a page from the critical pool.  For now, only singleton (order 0) 
>>pages are supported.
> 
> 
> How are you going to limit the number of GFP_CRITICAL
> allocations to something smaller than the number of
> pages in the pool ?

We can't.


> Unless you can do that, all guarantees are off...

Well, I was careful not to use the word guarantee in my post. ;)  The idea
is not to offer a 100% guarantee that the pool will never be exhausted.
The idea is to offer a pool that, sized appropriately, offers a very good
chance of surviving your emergency situation.  The definition of what is a
critical allocation and what the emergency situation is left intentionally
somewhat vague, so as to offer more flexibility.  For our use, certain
networking allocations are critical and our emergency situation is a 2
minute window of potential exreme memory pressure.  For others it could be
something completely different, but the expectation is that the emergency
situation would be of a finite time, since the pool is a fixed size.

Thanks!

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
