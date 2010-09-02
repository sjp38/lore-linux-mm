Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5BDB76B0047
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 13:39:53 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o82HTZNR021525
	for <linux-mm@kvack.org>; Thu, 2 Sep 2010 11:29:35 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o82Hdmq2102628
	for <linux-mm@kvack.org>; Thu, 2 Sep 2010 11:39:48 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o82HdmQA026134
	for <linux-mm@kvack.org>; Thu, 2 Sep 2010 11:39:48 -0600
Message-ID: <4C7FE163.4000906@austin.ibm.com>
Date: Thu, 02 Sep 2010 12:39:47 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/8] v5 De-couple sysfs memory directories from memory
 sections
References: <4C60407C.2080608@austin.ibm.com> <20100831215745.GA7641@kryten>
In-Reply-To: <20100831215745.GA7641@kryten>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Anton Blanchard <anton@samba.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Greg KH <greg@kroah.com>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On 08/31/2010 04:57 PM, Anton Blanchard wrote:
> 
> Hi Nathan,
> 
>> This set of patches de-couples the idea that there is a single
>> directory in sysfs for each memory section.  The intent of the
>> patches is to reduce the number of sysfs directories created to
>> resolve a boot-time performance issue.  On very large systems
>> boot time are getting very long (as seen on powerpc hardware)
>> due to the enormous number of sysfs directories being created.
>> On a system with 1 TB of memory we create ~63,000 directories.
>> For even larger systems boot times are being measured in hours.
>>
>> This set of patches allows for each directory created in sysfs
>> to cover more than one memory section.  The default behavior for
>> sysfs directory creation is the same, in that each directory
>> represents a single memory section.  A new file 'end_phys_index'
>> in each directory contains the physical_id of the last memory
>> section covered by the directory so that users can easily
>> determine the memory section range of a directory.
> 
> I tested this on a POWER7 with 2TB memory and the boot time improved from
> greater than 6 hours (I gave up), to under 5 minutes. Nice!

Thanks for testing this out.  I was able to test this on a 1 TB system
and saw memory sysfs creation times go from 10 minutes to a few seconds.
It's good to see the difference for a 2 TB system.

-Nathan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
