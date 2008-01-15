Message-ID: <478C6421.1080802@qumranet.com>
Date: Tue, 15 Jan 2008 09:43:29 +0200
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [kvm-devel] mmu notifiers
References: <20080109181908.GS6958@v2.random>	<Pine.LNX.4.64.0801091352320.12335@schroedinger.engr.sgi.com>	<47860512.3040607@qumranet.com>	<Pine.LNX.4.64.0801101103470.20353@schroedinger.engr.sgi.com>	<47891A5C.8060907@qumranet.com> <20080113120939.GA3221@sgi.com>	<478A03D8.9050308@qumranet.com> <Pine.LNX.4.64.0801141150010.8300@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0801141150010.8300@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: kvm-devel@lists.sourceforge.net, linux-mm@kvack.org, Daniel J Blueman <daniel.blueman@quadrics.com>, Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Sun, 13 Jan 2008, Avi Kivity wrote:
>
>   
>> I was just explaining how kvm shares memory among guests (which does not
>> require mmu notifiers); if you have some other configuration that can benefit
>> from mmu notifiers, then, well, great.
>>     
>
> I think you have two page tables pointing to the same memory location 
> right (not to page structs but two ptes)? Without a mmu notifier the pages 
> in this memory range cannot be evicted because otherwise ptes of the other 
> instance will point to a page that is now used for a different purpose.
>   

Even with just one guest we can't swap well without mmu notifiers.

kvm constructs new page tables for the guest that the Linux vm doesn't 
know about, so when Linux removes all the ptes, we need a callback to 
remove the kvm private ptes (and tlb entries).

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
