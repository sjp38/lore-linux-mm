Message-ID: <46118943.2020506@google.com>
Date: Mon, 02 Apr 2007 15:52:51 -0700
From: Martin Bligh <mbligh@google.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] x86_64: Switch to SPARSE_VIRTUAL
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0704021422040.2272@schroedinger.engr.sgi.com> <1175550968.22373.122.camel@localhost.localdomain> <200704030031.24898.ak@suse.de> <Pine.LNX.4.64.0704021534100.25602@schroedinger.engr.sgi.com> <461186A7.2020803@google.com> <Pine.LNX.4.64.0704021546520.24316@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0704021546520.24316@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, Dave Hansen <hansendc@us.ibm.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Mon, 2 Apr 2007, Martin Bligh wrote:
> 
>>> For 64GB you'd need 256M which would be a quarter of low mem. Probably takes
>>> up too much of low mem.
>> Yup.
> 
> We could move whatever you currently use to handle that into i386 arch 
> code. Or are there other platforms that do similar tricks with highmem?
> 
> We already have special hooks for node lookups in sparsemem. Move all of 
> that off into some arch dir?

Well, all I did was basically an early vmalloc kind of thing.

You only need to allocate enough virtual space for how much memory
you actually *have*, not the full set. The problem on i386 is that
you just need to reserve that space early, in order to shuffle
everything else into fit. It's messy, but not hard.

M.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
