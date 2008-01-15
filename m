Message-ID: <478C62F8.2070702@qumranet.com>
Date: Tue, 15 Jan 2008 09:38:32 +0200
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [kvm-devel] mmu notifiers
References: <20080109181908.GS6958@v2.random>	<Pine.LNX.4.64.0801091352320.12335@schroedinger.engr.sgi.com>	<47860512.3040607@qumranet.com>	<Pine.LNX.4.64.0801101103470.20353@schroedinger.engr.sgi.com>	<47891A5C.8060907@qumranet.com> <Pine.LNX.4.64.0801141148540.8300@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0801141148540.8300@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: kvm-devel@lists.sourceforge.net, linux-mm@kvack.org, Daniel J Blueman <daniel.blueman@quadrics.com>, Andrea Arcangeli <andrea@qumranet.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Sat, 12 Jan 2008, Avi Kivity wrote:
>
>   
>> Two kvm instances mmap() the file (from anywhere) into the guest address
>> space.  That memory is shared, and will be backed by the same page structs at
>> the same offset.
>>     
>
> Duh. Impossible. Two instances of Linux cannot share page structs. So how 
> are you doing this? Or is this just an idea?
>
>   

I was describing one Linux host running two guest instances.  The page 
structs are in the host, so they are shared by mmap().

kvm userspace is just an ordinary host process, it can mmap() any file 
it likes and then assign that virtual memory range to the guest (as 
guest physical memory).

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
