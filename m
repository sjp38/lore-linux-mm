Date: Tue, 14 Sep 2004 06:34:07 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] shrink per_cpu_pages to fit 32byte cacheline
Message-ID: <20040914093407.GA23935@logos.cnet>
References: <20040913233835.GA23894@logos.cnet> <1095142204.2698.12.camel@laptop.fenrus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1095142204.2698.12.camel@laptop.fenrus.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjanv@redhat.com>
Cc: akpm@osdl.org, "Martin J. Bligh" <mbligh@aracnet.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 14, 2004 at 08:10:04AM +0200, Arjan van de Ven wrote:
> On Tue, 2004-09-14 at 01:38, Marcelo Tosatti wrote:
> > Subject says it all, the following patch shrinks per_cpu_pages
> > struct from 24 to 16bytes, that makes the per CPU array containing
> > hot and cold "per_cpu_pages[2]" fit on 32byte cacheline. This structure
> > is often used so I bet this is a useful optimization.
> 
> I'm not sure it's worth it. cachelines are 64 or 128 bytes nowadays and
> a short access costs you at least 1 extra cycle per access on several
> x86 cpus (byte and dword are cheap, short is not)

I changed the counters to short thinking about 32 byte cacheline machines.  

There are a lot of non-x86 boxes which have 32 byte cachelines (embedded) and which 
will continue to have such AFAIK.

How come short access can cost 1 extra cycle? Because you need two "read bytes" ?
It doesnt make much sense to me. I should go look into gcc asm output.

If that's true we should also undo the pagevec shrinking which went into -mm5.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
