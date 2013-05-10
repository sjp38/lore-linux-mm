Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 852F46B0033
	for <linux-mm@kvack.org>; Fri, 10 May 2013 11:57:46 -0400 (EDT)
Received: by mail-ie0-f173.google.com with SMTP id k5so8330102iea.4
        for <linux-mm@kvack.org>; Fri, 10 May 2013 08:57:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130509165717.GA9548@medulla>
References: <518BB132.5050802@gmail.com>
	<518BB3B1.8010207@gmail.com>
	<20130509165717.GA9548@medulla>
Date: Fri, 10 May 2013 11:57:45 -0400
Message-ID: <CALS39Muh6-AoGBF0odz4OuMaDojdhJAd6D6y2emuApjQbk8LLw@mail.gmail.com>
Subject: Re: misunderstanding of the virtual memory
From: Benjamin Teissier <ben.teissier@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org

2013/5/9, Seth Jennings <sjenning@linux.vnet.ibm.com>:
> On Thu, May 09, 2013 at 10:33:21AM -0400, Ben Teissier wrote:
>>
>> Hi,
>>
>> I'm Benjamin and I'm studying the kernel. I write you this email
>> because I've a trouble with the mmu and the virtual memory. I try to
>> understand how a program (user land) can write something into the stack
>> (push ebp, for example), indeed, the program works with virtual address
>> (between 0x00000 and 0x8... if my memory is good) but at the hardware
>> side the address is not the same (that's why mmu was created, if I'm
>> right).
>
> Yes, this is the purpose of pages tables; to map virtual addresses to real
> memory addresses (more precisely virtual memory _pages_ to real memory
> pages).
>
>>
>> My problem is the following : how the data is wrote on the physical
>> memory. When I try a strace (kernel 2.6.32 on a simple program) I have
>> no hint on the transfer of data. Moreover, according to the wikipedia
>> web page on syscall (
>> https://en.wikipedia.org/wiki/System_call#The_library_as_an_intermediary
>> ), a call is not managed by the kernel. So, how the transfer between
>> virtual memory and physical memory is possible ?
>
> That is because writing to a memory location in userspace isn't an
> operation
> that requires a syscall or any kind of kernel intervention at all.  It is
> an
> assembly store instruction executed directly on the CPU by the program.
> The
> only time the kernel is involved in a store operation is if the virtual
> address
> translation doesn't exist in the TLB (or is write-protected, etc..), in
> which
> case the hardware generates a fault so the kernel take the required action
> to
> populate the TLB with the translation.
>
> Hope this answers your question.
>
> Seth
>
>

Hi,

Your answer is perfect, thanks a lot for your help !

Benjamin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
