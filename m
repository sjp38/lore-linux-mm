Received: by zproxy.gmail.com with SMTP id v1so1105874nzb
        for <linux-mm@kvack.org>; Wed, 07 Sep 2005 18:54:08 -0700 (PDT)
Message-ID: <aec7e5c305090718543e2ff047@mail.gmail.com>
Date: Thu, 8 Sep 2005 10:54:08 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Reply-To: magnus.damm@gmail.com
Subject: Re: [PATCH] i386: single node SPARSEMEM fix
In-Reply-To: <20050907164945.14aba736.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20050906035531.31603.46449.sendpatchset@cherry.local>
	 <1126114116.7329.16.camel@localhost> <512850000.1126117362@flay>
	 <1126117674.7329.27.camel@localhost> <521510000.1126118091@flay>
	 <20050907164945.14aba736.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: "Martin J. Bligh" <mbligh@mbligh.org>, haveblue@us.ibm.com, magnus@valinux.co.jp, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andyw@uk.ibm.com
List-ID: <linux-mm.kvack.org>

On 9/8/05, Andrew Morton <akpm@osdl.org> wrote:
> "Martin J. Bligh" <mbligh@mbligh.org> wrote:
> >
> >
> >
> > --On Wednesday, September 07, 2005 11:27:54 -0700 Dave Hansen <haveblue@us.ibm.com> wrote:
> >
> > > On Wed, 2005-09-07 at 11:22 -0700, Martin J. Bligh wrote:
> > >> CONFIG_NUMA was meant to (and did at one point) support both NUMA and flat
> > >> machines. This is essential in order for the distros to support it - same
> > >> will go for sparsemem.
> > >
> > > That's a different issue.  The current code works if you boot a NUMA=y
> > > SPARSEMEM=y machine with a single node.  The current Kconfig options
> > > also enforce that SPARSEMEM depends on NUMA on i386.
> > >
> > > Magnus would like to enable SPARSEMEM=y while CONFIG_NUMA=n.  That
> > > requires some Kconfig changes, as well as an extra memory present call.
> > > I'm questioning why we need to do that when we could never do
> > > DISCONTIG=y while NUMA=n on i386.
> >
> > Ah, OK - makes more sense. However, some machines do have large holes
> > in e820 map setups - is not really critical, more of an efficiency
> > thing.
> 
> Confused.   Does all this mean that we want the patch, or not?

What about if I remove the Kconfig stuff and just keep the "fix" for
the non-NUMA version of setup_memory()?

/ magnus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
