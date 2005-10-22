Date: Sat, 22 Oct 2005 19:13:58 +0200
From: Arjan van de Ven <arjanv@redhat.com>
Subject: ia64 page size (was Re: [PATCH] per-page SLAB freeing (only dcache for now))
Message-ID: <20051022171358.GA31619@devserv.devel.redhat.com>
References: <Pine.LNX.4.62.0509301934390.31011@schroedinger.engr.sgi.com> <20051001215254.GA19736@xeon.cnet> <Pine.LNX.4.62.0510030823420.7812@schroedinger.engr.sgi.com> <43419686.60600@colorfullife.com> <20051003221743.GB29091@logos.cnet> <4342B623.3060007@colorfullife.com> <20051006160115.GA30677@logos.cnet> <20051022013001.GE27317@logos.cnet> <20051021233111.58706a2e.akpm@osdl.org> <Pine.LNX.4.62.0510221002020.27511@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0510221002020.27511@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, manfred@colorfullife.com, linux-mm@kvack.org, dgc@sgi.com, dipankar@in.ibm.com, mbligh@mbligh.org
List-ID: <linux-mm.kvack.org>

On Sat, Oct 22, 2005 at 10:08:52AM -0700, Christoph Lameter wrote:
> There are been versions of Linux for IA64 out there with 64k pagesize on 
> IA64 and there is the possibility that we need to switch to 64k as a 
> standard next year when we may have single OS images running with more 
> than 16TB Ram.

it's a kernel config option, and it has to remain that way; the pagesize is
a userspace visible property and although apps aren't supposed to care..
some do. So Distros that use 16kb right now (the RH ones) will need to keep
16Kb pagesize... 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
