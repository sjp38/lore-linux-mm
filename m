Subject: Re: [PATCH] i386: single node SPARSEMEM fix
From: Magnus Damm <magnus@valinux.co.jp>
In-Reply-To: <40650000.1126159888@[10.10.2.4]>
References: <20050906035531.31603.46449.sendpatchset@cherry.local>
	 <1126114116.7329.16.camel@localhost><512850000.1126117362@flay>
	 <1126117674.7329.27.camel@localhost><521510000.1126118091@flay>
	 <20050907164945.14aba736.akpm@osdl.org>  <40650000.1126159888@[10.10.2.4]>
Content-Type: text/plain
Date: Thu, 08 Sep 2005 15:36:29 +0900
Message-Id: <1126161389.6940.61.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Andrew Morton <akpm@osdl.org>, haveblue@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andyw@uk.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, 2005-09-07 at 23:11 -0700, Martin J. Bligh wrote:
> >> >> CONFIG_NUMA was meant to (and did at one point) support both NUMA and flat
> >> >> machines. This is essential in order for the distros to support it - same
> >> >> will go for sparsemem.
> >> > 
> >> > That's a different issue.  The current code works if you boot a NUMA=y
> >> > SPARSEMEM=y machine with a single node.  The current Kconfig options
> >> > also enforce that SPARSEMEM depends on NUMA on i386.
> >> > 
> >> > Magnus would like to enable SPARSEMEM=y while CONFIG_NUMA=n.  That
> >> > requires some Kconfig changes, as well as an extra memory present call.
> >> > I'm questioning why we need to do that when we could never do
> >> > DISCONTIG=y while NUMA=n on i386.
> >> 
> >> Ah, OK - makes more sense. However, some machines do have large holes
> >> in e820 map setups - is not really critical, more of an efficiency
> >> thing.
> > 
> > Confused.   Does all this mean that we want the patch, or not?
> 
> >From that POV, nothing urgent, and would require more work to make use
> of it anyway. Not sure if Magnus had another more immediate use for it?

Just wanted to make sure that both versions of setup_memory() behaved in
a similar way and they both called memory_present(). But nothing urgent,
and no immediate use.

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
