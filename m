Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 87A5F6B0078
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 14:18:56 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8SI3Ge6029278
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 14:03:16 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8SIIsMT344258
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 14:18:54 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8SIIr72023610
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 15:18:54 -0300
Message-ID: <4CA23185.2060905@austin.ibm.com>
Date: Tue, 28 Sep 2010 13:18:45 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 8/8] v2 Update memory hotplug documentation
References: <4CA0EBEB.1030204@austin.ibm.com> <4CA0F076.1070803@austin.ibm.com> <4CA1E36A.2000005@redhat.com>
In-Reply-To: <4CA1E36A.2000005@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 09/28/2010 07:45 AM, Avi Kivity wrote:
>  On 09/27/2010 09:28 PM, Nathan Fontenot wrote:
>>
>>   For example, assume 1GiB section size. A device for a memory
>> starting at
>>   0x100000000 is /sys/device/system/memory/memory4
>>   (0x100000000 / 1Gib = 4)
>>   This device covers address range [0x100000000 ... 0x140000000)
>>
>> -Under each section, you can see 4 files.
>> +Under each section, you can see 5 files.
> 
> Shouldn't this be, 4 or 5 files depending on kernel version?
> 

Correct,  I'll update this.  Thanks.

-Nathan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
