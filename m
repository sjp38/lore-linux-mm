Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2921F6B004A
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 14:22:56 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8SILiJG017794
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 14:21:45 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8SILWAR332614
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 14:21:32 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8SILTWK007632
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 15:21:32 -0300
Message-ID: <4CA231FA.4070907@austin.ibm.com>
Date: Tue, 28 Sep 2010 13:20:42 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/8] v2 Allow memory block to span multiple memory sections
References: <4CA0EBEB.1030204@austin.ibm.com> <4CA0EFAA.8050000@austin.ibm.com> <20100928124810.GI14068@sgi.com>
In-Reply-To: <20100928124810.GI14068@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 09/28/2010 07:48 AM, Robin Holt wrote:
>> +u32 __weak memory_block_size_bytes(void)
>> +{
>> +	return MIN_MEMORY_BLOCK_SIZE;
>> +}
>> +
>> +static u32 get_memory_block_size(void)
> 
> Can we make this an unsigned long?  We are testing on a system whose
> smallest possible configuration is 4GB per socket with 512 sockets.
> We would like to be able to specify this as 2GB by default (results
> in the least lost memory) and suggest we add a command line option
> which overrides this value.  We have many installations where 16GB may
> be optimal.  Large configurations will certainly become more prevalent.

Works for me.

> 
> ...
>> @@ -551,12 +608,16 @@
>>  	unsigned int i;
>>  	int ret;
>>  	int err;
>> +	int block_sz;
> 
> This one needs to match the return above.  In our tests, we ended up
> with a negative sections_per_block which caused very unexpected results.

Oh, nice catch.  I'll update both of these.

-Nathan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
