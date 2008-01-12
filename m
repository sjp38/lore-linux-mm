Message-ID: <47891A5C.8060907@qumranet.com>
Date: Sat, 12 Jan 2008 21:51:56 +0200
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [kvm-devel] mmu notifiers
References: <20080109181908.GS6958@v2.random> <Pine.LNX.4.64.0801091352320.12335@schroedinger.engr.sgi.com> <47860512.3040607@qumranet.com> <Pine.LNX.4.64.0801101103470.20353@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0801101103470.20353@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, kvm-devel@lists.sourceforge.net, linux-mm@kvack.org, Daniel J Blueman <daniel.blueman@quadrics.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Thu, 10 Jan 2008, Avi Kivity wrote:
>
>   
>> Actually sharing memory is possible even without this patch; one simply
>> mmap()s a file into the address space of both guests.  Or are you referring to
>> something else?
>>     
>
> A file from where? If a file is read by two guests then they will have 
> distinct page structs.
>
>   

Two kvm instances mmap() the file (from anywhere) into the guest address 
space.  That memory is shared, and will be backed by the same page 
structs at the same offset.

-- 
Any sufficiently difficult bug is indistinguishable from a feature.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
