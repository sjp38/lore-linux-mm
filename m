Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1CE8A6B003D
	for <linux-mm@kvack.org>; Tue,  5 May 2009 02:07:26 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 5so2366821ywm.26
        for <linux-mm@kvack.org>; Mon, 04 May 2009 23:07:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <82459C1E-87E6-497C-8D09-21FD5FA5709E@marksmachinations.com>
References: <49FED524.9020602@gmail.com>
	 <82459C1E-87E6-497C-8D09-21FD5FA5709E@marksmachinations.com>
Date: Tue, 5 May 2009 14:07:31 +0800
Message-ID: <41d311580905042307t75ad393eo35e9b90aa15486b2@mail.gmail.com>
Subject: Re: Memory Concepts [+Newbie]
From: Pei Lin <telent997@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mark Brown <markb@marksmachinations.com>
Cc: Marcos Roriz <marcosrorizinf@gmail.com>, kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

That book << Understating the Linux Virtual Memory Manager>> clearly
elaborate why ZONE_NORMAL is 896 on the section 4.1 Linear Address
Space.

SEE  the comment about ZONE_HIGHMEM,  include/linux/mmzone.h

#ifdef CONFIG_HIGHMEM
        /*
         * A memory area that is only addressable by the kernel through
         * mapping portions into its own address space. This is for example
         * used by i386 to allow the kernel to address the memory beyond
         * 900MB. The kernel will set up special mappings (page
         * table entries on i386) for each page that the kernel needs to
         * access.
         */
        ZONE_HIGHMEM,
#endif


2009/5/4 Mark Brown <markb@marksmachinations.com>:
> Hi Marcos,
>
> A memory bank for RAM is just an individual addressable array on a memory
> board. The addressing of the bank is managed by the memory controller.
>
> Regards,
> -- Mark
>
> On May 4, 2009, at 7:44 AM, Marcos Roriz wrote:
>
>> I'm reading Mel Gorman Understating the Linux Virtual Memory Manager and
>> also TANENBAUM Modern Operating System I don't get some basic concepts of
>> the Memory Management in Linux Kernel.
>>
>> The first question is, what is a memory bank, It's not clear if its a
>> physical section of the memory of if its a chip (physical) itself.
>>
>> The ZONE_NORMAL zone refer only to kernel direct memory mapped, that means
>> only to kernel pages and kernel programs (such as daemons)?
>>
>> Why is the ZONE_NORMAL so large (896 MB)? How to deal with low memory
>> systems?
>>
>> The ZONE_HIGHMEM zone refer to kernel not mapped directly, so that
>> includes userspace programs right?
>>
>> I googled and searched for all those answers but couldn't find a direct
>> and consistent answer, thats why I'm asking for your guys help.
>>
>> Thanks very much for you time,
>>
>> Marcos Roriz
>>
>> --
>> To unsubscribe from this list: send an email with
>> "unsubscribe kernelnewbies" to ecartis@nl.linux.org
>> Please read the FAQ at http://kernelnewbies.org/FAQ
>>
>
>
> --
> To unsubscribe from this list: send an email with
> "unsubscribe kernelnewbies" to ecartis@nl.linux.org
> Please read the FAQ at http://kernelnewbies.org/FAQ
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
