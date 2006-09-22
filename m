Message-ID: <4514441E.70207@mbligh.org>
Date: Fri, 22 Sep 2006 13:14:22 -0700
From: Martin Bligh <mbligh@mbligh.org>
MIME-Version: 1.0
Subject: Re: [RFC] Initial alpha-0 for new page allocator API
References: <Pine.LNX.4.64.0609212052280.4736@schroedinger.engr.sgi.com> <200609222110.25118.ak@suse.de> <1158955850.24572.37.camel@localhost.localdomain> <200609222202.41692.ak@suse.de>
In-Reply-To: <200609222202.41692.ak@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Christoph Lameter <clameter@sgi.com>, akpm@google.com, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, James Bottomley <James.Bottomley@steeleye.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> And is fine with 16MB anyways I think.
> 
> 
>>- Some aacraid, mostly only for control structures. Those found on 64bit
>>are probably fine with slow alloc.
> 
> 
> That is the only case where there are rumours they are not fine with 16MB.
> 
> 
>>- Broadcom stuff - not sure if 30 or 31bit, around today and on 64bit
> 
> 
> b44 is 30bit. That's true. I even got one here.
> 
> But it doesn't count really because we can handle it fine with existing 
> 16MB GFP_DMA

The problem is that GFP_DMA does not mean 16MB on all architectures.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
