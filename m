Date: Mon, 20 Aug 2007 14:17:27 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 2/9] Use NOMEMALLOC reclaim to allow reclaim if PF_MEMALLOC
 is set
In-Reply-To: <1187644449.5337.48.camel@lappy>
Message-ID: <Pine.LNX.4.64.0708201415260.31167@schroedinger.engr.sgi.com>
References: <20070814153021.446917377@sgi.com>  <20070814153501.305923060@sgi.com>
 <20070818071035.GA4667@ucw.cz>  <Pine.LNX.4.64.0708201158270.28863@schroedinger.engr.sgi.com>
  <1187641056.5337.32.camel@lappy>  <Pine.LNX.4.64.0708201323590.30053@schroedinger.engr.sgi.com>
 <1187644449.5337.48.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, 20 Aug 2007, Peter Zijlstra wrote:

> > Its not that different.
> 
> Yes it is, disk based completion does not require memory, network based
> completion requires unbounded memory.

Disk based completion only require no memory if its not on a stack of 
other devices and if the interrupt handles is appropriately shaped. If 
there are multile levels below or there is some sort of complex 
completion handling then this also may require memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
