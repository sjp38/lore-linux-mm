Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3D4546B0078
	for <linux-mm@kvack.org>; Fri,  1 Oct 2010 14:57:01 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o91IlTgU013286
	for <linux-mm@kvack.org>; Fri, 1 Oct 2010 12:47:29 -0600
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o91IuuDa124722
	for <linux-mm@kvack.org>; Fri, 1 Oct 2010 12:56:56 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o91IuuBf009046
	for <linux-mm@kvack.org>; Fri, 1 Oct 2010 12:56:56 -0600
Message-ID: <4CA62EF6.8000204@austin.ibm.com>
Date: Fri, 01 Oct 2010 13:56:54 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/9] v3 Allow memory blocks to span multiple memory sections
References: <4CA62700.7010809@austin.ibm.com> <4CA62917.80008@austin.ibm.com> <20101001185250.GK14064@sgi.com>
In-Reply-To: <20101001185250.GK14064@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

On 10/01/2010 01:52 PM, Robin Holt wrote:
> On Fri, Oct 01, 2010 at 01:31:51PM -0500, Nathan Fontenot wrote:
>> Update the memory sysfs code such that each sysfs memory directory is now
>> considered a memory block that can span multiple memory sections per
>> memory block.  The default size of each memory block is SECTION_SIZE_BITS
>> to maintain the current behavior of having a single memory section per
>> memory block (i.e. one sysfs directory per memory section).
>>
>> For architectures that want to have memory blocks span multiple
>> memory sections they need only define their own memory_block_size_bytes()
>> routine.
>>
>> Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>
>>
>> ---
>>  drivers/base/memory.c |  155 ++++++++++++++++++++++++++++++++++----------------
>>  1 file changed, 108 insertions(+), 47 deletions(-)
>>
>> Index: linux-next/drivers/base/memory.c
>> ===================================================================
>> --- linux-next.orig/drivers/base/memory.c	2010-09-30 14:13:50.000000000 -0500
>> +++ linux-next/drivers/base/memory.c	2010-09-30 14:46:00.000000000 -0500
> ...
>> +static unsigned long get_memory_block_size(void)
>> +{
>> +	u32 block_sz;
>         ^^^
> 
> I think this should be unsigned long.  u32 will work, but everything
> else has been changed to use unsigned long.  If you disagree, I will
> happily acquiesce as nothing is currently broken.  If SGI decides to make
> memory_block_size_bytes more dynamic, we will fix this up at that time.

You're right, that should have been made an unsigned long also.  I'll attach a new
patch with that corrected.

-Nathan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
