Message-ID: <47861D3C.6070709@qumranet.com>
Date: Thu, 10 Jan 2008 15:27:24 +0200
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [kvm-devel] mmu notifiers
References: <20080109181908.GS6958@v2.random> <Pine.LNX.4.64.0801091352320.12335@schroedinger.engr.sgi.com> <47860512.3040607@qumranet.com> <20080110131612.GA1933@sgi.com>
In-Reply-To: <20080110131612.GA1933@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, kvm-devel@lists.sourceforge.net, linux-mm@kvack.org, Daniel J Blueman <daniel.blueman@quadrics.com>
List-ID: <linux-mm.kvack.org>

Robin Holt wrote:
>
>> The patch does enable some nifty things; one example you may be familiar 
>> with is using page migration to move a guest from one numa node to another.
>>     
>
> xpmem allows one MPI rank to "export" his address space, a different
> MPI rank to "import" that address space, and they share the same pages.
> This allows sharing of things like stack and heap space.  XPMEM also
> provides a mechanism to share that PFN information across partition
> boundaries so the pages become available on a different host.  This,
> of course, is dependent upon hardware that supports direct access to
> the memory by the processor.
>
>   

So this is yet another instance of hardware that has a tlb that needs to 
be kept in sync with the page tables, yes?

Excellent, the more users the patch has, the easier it will be to 
justify it.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
