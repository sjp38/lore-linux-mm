Message-ID: <20020404183821.25904.qmail@web12301.mail.yahoo.com>
Date: Thu, 4 Apr 2002 10:38:21 -0800 (PST)
From: Ravi <kravi26@yahoo.com>
Subject: Re: Memory allocation in Linux (fwd)
In-Reply-To: <Pine.LNX.4.21.0204041258240.24668-100000@mailhost.tifr.res.in>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Amit S. Jain" <amitjain@tifr.res.in>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


> Obtaining large amount of continuous memory from the kernel is not a
> good practice and is also not possible.However,as far as
> non-contiguous memory is concerned ...cant those be obtained in huge 
> amounts (I am talkin in terms of MB).Using get_free_pages or vmalloc 
> cant large amounts of memory be obtained.
 
  __get_free_pages() allocates physically contiguous pages, so it
doesn't help you.  vmalloc() may be used to get more memory than you
would with kmalloc(), but it isn't guaranteed to succeed. vmalloc can
fail for two reasons (AFAIK):
 - vmalloc maps physically discontiguous pages to kernel virtual
addresses in the range of VMALLOC_START and VMALLOC_END. If this
address range is used up, vmalloc will fail.
 - allocations done by vmalloc are always backed by physical pages. So
if enough physical memory is not available to satisfy the request,
vmalloc will fail.

Hope this helps,
Ravi.

__________________________________________________
Do You Yahoo!?
Yahoo! Tax Center - online filing with TurboTax
http://taxes.yahoo.com/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
