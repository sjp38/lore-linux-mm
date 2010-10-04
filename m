Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id F187F6B004A
	for <linux-mm@kvack.org>; Mon,  4 Oct 2010 10:48:06 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o94EP5W3025953
	for <linux-mm@kvack.org>; Mon, 4 Oct 2010 10:25:05 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o94EjJUC1441830
	for <linux-mm@kvack.org>; Mon, 4 Oct 2010 10:45:19 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o94EjI1i013778
	for <linux-mm@kvack.org>; Mon, 4 Oct 2010 11:45:19 -0300
Message-ID: <4CA9E87A.3000807@austin.ibm.com>
Date: Mon, 04 Oct 2010 09:45:14 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/9] v3 Define memory_block_size_bytes for powerpc/pseries
References: <4CA62700.7010809@austin.ibm.com> <4CA62A0A.4050406@austin.ibm.com> <20101003175500.GE7896@balbir.in.ibm.com> <20101003180731.GT14064@sgi.com> <1286129461.9970.1.camel@nimitz> <20101003182701.GI7896@balbir.in.ibm.com>
In-Reply-To: <20101003182701.GI7896@balbir.in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Robin Holt <holt@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Greg KH <greg@kroah.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

On 10/03/2010 01:27 PM, Balbir Singh wrote:
> * Dave Hansen <dave@linux.vnet.ibm.com> [2010-10-03 11:11:01]:
> 
>> On Sun, 2010-10-03 at 13:07 -0500, Robin Holt wrote:
>>> On Sun, Oct 03, 2010 at 11:25:00PM +0530, Balbir Singh wrote:
>>>> * Nathan Fontenot <nfont@austin.ibm.com> [2010-10-01 13:35:54]:
>>>>
>>>>> Define a version of memory_block_size_bytes() for powerpc/pseries such that
>>>>> a memory block spans an entire lmb.
>>>>
>>>> I hope I am not missing anything obvious, but why not just call it
>>>> lmb_size, why do we need memblock_size?
>>>>
>>>> Is lmb_size == memblock_size after your changes true for all
>>>> platforms?
>>>
>>> What is an lmb?  I don't recall anything like lmb being referred to in
>>> the rest of the kernel.
>>
>> Heh.  It's the OpenFirmware name for a Logical Memory Block.  Basically
>> what we use to determine the SECTION_SIZE on powerpc.  Probably not the
>> best terminology to use elsewhere in the kernel.
> 
> Agreed for the kernel, this patch was for powerpc/pseries, hence was
> checking in this context.
> 

I don't really see a reason to name it lmb_size, it seems easier
to stick with the naming used by the rest of the kernel.

-Nathan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
