Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CD76F6B0096
	for <linux-mm@kvack.org>; Mon,  4 May 2009 08:26:55 -0400 (EDT)
Message-Id: <82459C1E-87E6-497C-8D09-21FD5FA5709E@marksmachinations.com>
From: Mark Brown <markb@marksmachinations.com>
In-Reply-To: <49FED524.9020602@gmail.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0 (Apple Message framework v930.3)
Subject: Re: Memory Concepts [+Newbie]
Date: Mon, 4 May 2009 08:28:43 -0400
References: <49FED524.9020602@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Marcos Roriz <marcosrorizinf@gmail.com>
Cc: kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Marcos,

A memory bank for RAM is just an individual addressable array on a  
memory board. The addressing of the bank is managed by the memory  
controller.

Regards,
-- Mark

On May 4, 2009, at 7:44 AM, Marcos Roriz wrote:

> I'm reading Mel Gorman Understating the Linux Virtual Memory Manager  
> and also TANENBAUM Modern Operating System I don't get some basic  
> concepts of the Memory Management in Linux Kernel.
>
> The first question is, what is a memory bank, It's not clear if its  
> a physical section of the memory of if its a chip (physical) itself.
>
> The ZONE_NORMAL zone refer only to kernel direct memory mapped, that  
> means only to kernel pages and kernel programs (such as daemons)?
>
> Why is the ZONE_NORMAL so large (896 MB)? How to deal with low  
> memory systems?
>
> The ZONE_HIGHMEM zone refer to kernel not mapped directly, so that  
> includes userspace programs right?
>
> I googled and searched for all those answers but couldn't find a  
> direct and consistent answer, thats why I'm asking for your guys help.
>
> Thanks very much for you time,
>
> Marcos Roriz
>
> --
> To unsubscribe from this list: send an email with
> "unsubscribe kernelnewbies" to ecartis@nl.linux.org
> Please read the FAQ at http://kernelnewbies.org/FAQ
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
