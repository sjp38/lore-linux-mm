Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2F0AA6B004A
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 11:18:01 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8UFABWf001793
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 09:10:11 -0600
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8UFHtY7079402
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 09:17:55 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8UFLeWW009474
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 09:21:41 -0600
Message-ID: <4CA4AA21.9030109@austin.ibm.com>
Date: Thu, 30 Sep 2010 10:17:53 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/8] v2 De-Couple sysfs memory directories from memory
 sections
References: <4CA0EBEB.1030204@austin.ibm.com> <20100928123848.GH14068@sgi.com> <4CA2313D.2030508@austin.ibm.com> <20100929192830.GK14068@sgi.com>
In-Reply-To: <20100929192830.GK14068@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 09/29/2010 02:28 PM, Robin Holt wrote:
> On Tue, Sep 28, 2010 at 01:17:33PM -0500, Nathan Fontenot wrote:
>> On 09/28/2010 07:38 AM, Robin Holt wrote:
>>> I was tasked with looking at a slowdown in similar sized SGI machines
>>> booting x86_64.  Jack Steiner had already looked into the memory_dev_init.
>>> I was looking at link_mem_sections().
>>>
>>> I made a dramatic improvement on a 16TB machine in that function by
>>> merely caching the most recent memory section and checking to see if
>>> the next memory section happens to be the subsequent in the linked list
>>> of kobjects.
>>>
>>> That simple cache reduced the time for link_mem_sections from 1 hour 27
>>> minutes down to 46 seconds.
>>
>> Nice!
>>
>>>
>>> I would like to propose we implement something along those lines also,
>>> but I am currently swamped.  I can probably get you a patch tomorrow
>>> afternoon that applies at the end of this set.
>>
>> Should this be done as a separate patch?  This patch set concentrates on
>> updates to the memory code with the node updates only being done due to the
>> memory changes.
>>
>> I think its a good idea to do the caching and have no problem adding on to
>> this patchset if no one else has any objections.
> 
> I am sorry.  I had meant to include you on the Cc: list.  I just posted a
> set of patches (3 small patches) which implement the cache most recent bit
> I aluded to above.  Search for a subject of "Speed up link_mem_sections
> during boot" and you will find them.  I did add you to the Cc: list for
> the next time I end up sending the set.
> 
> My next task is to implement a x86_64 SGI UV specific chunk of code
> to memory_block_size_bytes().  Would you consider adding that to your
> patch set?  I expect to have that either later today or early tomorrow.
> 

No problem. I'm putting together a new patch set with updates from all of
the comments now so go ahead and send it to me when you have it ready.

-Nathan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
