Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D75FF60080E
	for <linux-mm@kvack.org>; Tue, 10 Aug 2010 08:17:26 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7ACGkl5008804
	for <linux-mm@kvack.org>; Tue, 10 Aug 2010 08:16:46 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7ACHKxd276288
	for <linux-mm@kvack.org>; Tue, 10 Aug 2010 08:17:20 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7ACHKFJ010675
	for <linux-mm@kvack.org>; Tue, 10 Aug 2010 08:17:20 -0400
Message-ID: <4C61434F.7060808@austin.ibm.com>
Date: Tue, 10 Aug 2010 07:17:19 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 8/8] v5  Update memory-hotplug documentation
References: <4C60407C.2080608@austin.ibm.com> <4C604C62.7060509@austin.ibm.com> <201008091344.37878.nacc@us.ibm.com>
In-Reply-To: <201008091344.37878.nacc@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Greg KH <greg@kroah.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On 08/09/2010 03:44 PM, Nishanth Aravamudan wrote:
> On Monday, August 09, 2010 11:43:46 am Nathan Fontenot wrote:
>> Update the memory hotplug documentation to reflect the new behaviors of
>> memory blocks reflected in sysfs.
> 
> <snip>
> 
>> Index: linux-2.6/Documentation/memory-hotplug.txt
>> ===================================================================
>> --- linux-2.6.orig/Documentation/memory-hotplug.txt	2010-08-09 07:36:48.000000000 -0500
>> +++ linux-2.6/Documentation/memory-hotplug.txt	2010-08-09 07:59:54.000000000 -0500
> 
> <snip>
> 
>> -/sys/devices/system/memory/memoryXXX/phys_index
>> +/sys/devices/system/memory/memoryXXX/start_phys_index
>> +/sys/devices/system/memory/memoryXXX/end_phys_index
>>  /sys/devices/system/memory/memoryXXX/phys_device
>>  /sys/devices/system/memory/memoryXXX/state
>>  /sys/devices/system/memory/memoryXXX/removable
>>
>> -'phys_index' : read-only and contains section id, same as XXX.
> 
> <snip>
> 
>> +'phys_index'      : read-only and contains section id of the first section
> 
> Shouldn't this be "start_phys_index"?

Hmmm... looks like  I missed something in the documentation.

The property should be 'phys_index'.  I thought about changing it to
'start_phys_index' but that was rejected.  The listing of the files
above is wrong in this patch, it should be 

 +/sys/devices/system/memory/memoryXXX/phys_index
 +/sys/devices/system/memory/memoryXXX/end_phys_index

Thanks, 

Nathan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
