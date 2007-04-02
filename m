Date: Mon, 2 Apr 2007 15:37:56 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/4] x86_64: Switch to SPARSE_VIRTUAL
In-Reply-To: <200704030031.24898.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0704021534100.25602@schroedinger.engr.sgi.com>
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0704021422040.2272@schroedinger.engr.sgi.com>
 <1175550968.22373.122.camel@localhost.localdomain> <200704030031.24898.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Dave Hansen <hansendc@us.ibm.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Apr 2007, Andi Kleen wrote:

> If it works I would be inclined to replaced old sparsemem with Christoph's
> new one on x86-64. Perhaps that could cut down the bewildering sparsemem
> ifdef jungle that is there currently.
> 
> But I presume it won't work on 32bit because of the limited address space?

Not in general but it will work in non PAE mode. 4GB need 2^(32-21+4) = 
16MB pages. This would require the mapping on 4 4MB pages.

For 64GB you'd need 256M which would be a quarter of low mem. Probably 
takes up too much of low mem.

> > But, without some cold, hard, data, we mere mortals without the 1024-way
> > machines can only guess. ;)
> 
> Yep.
> 
> -Andi (who would be scared of a 1024 way x86 machine)

- Christoph (who does not believe that Andi has to wait long for 
something bigger)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
