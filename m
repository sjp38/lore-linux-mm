Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 058356B02A5
	for <linux-mm@kvack.org>; Mon,  9 Aug 2010 09:56:19 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o79Dfge7023007
	for <linux-mm@kvack.org>; Mon, 9 Aug 2010 09:41:42 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o79DuDbi371916
	for <linux-mm@kvack.org>; Mon, 9 Aug 2010 09:56:13 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o79DttSl026410
	for <linux-mm@kvack.org>; Mon, 9 Aug 2010 07:55:56 -0600
Message-ID: <4C6008EA.8040601@austin.ibm.com>
Date: Mon, 09 Aug 2010 08:55:54 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/9] v4  Add mutex for add/remove of memory blocks
References: <4C581A6D.9030908@austin.ibm.com>	<4C581C26.5080007@austin.ibm.com> <20100805135314.7229d07c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100805135314.7229d07c.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On 08/04/2010 11:53 PM, KAMEZAWA Hiroyuki wrote:
> On Tue, 03 Aug 2010 08:39:50 -0500
> Nathan Fontenot <nfont@austin.ibm.com> wrote:
> 
>> Add a new mutex for use in adding and removing of memory blocks.  This
>> is needed to avoid any race conditions in which the same memory block could
>> be added and removed at the same time.
>>
>> Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> But a nitpick (see below)
> 
>> ---
>>  drivers/base/memory.c |    9 +++++++++
>>  1 file changed, 9 insertions(+)
>>
>> Index: linux-2.6/drivers/base/memory.c
>> ===================================================================
>> --- linux-2.6.orig/drivers/base/memory.c	2010-08-02 13:35:00.000000000 -0500
>> +++ linux-2.6/drivers/base/memory.c	2010-08-02 13:45:34.000000000 -0500
>> @@ -27,6 +27,8 @@
>>  #include <asm/atomic.h>
>>  #include <asm/uaccess.h>
>>  
>> +static struct mutex mem_sysfs_mutex;
>> +
> 
> For static symbol of mutex, we usually do
> 	static DEFINE_MUTEX(mem_sysfs_mutex);
> 
> Then, extra calls of mutex_init() is not required.
> 

ok,  fixed in the next version of the patches.

-Nathan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
