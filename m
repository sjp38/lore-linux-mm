Received: by zproxy.gmail.com with SMTP id v1so1104482nzb
        for <linux-mm@kvack.org>; Wed, 07 Sep 2005 18:40:39 -0700 (PDT)
Message-ID: <aec7e5c3050907184033423e69@mail.gmail.com>
Date: Thu, 8 Sep 2005 10:40:39 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Reply-To: magnus.damm@gmail.com
Subject: Re: [PATCH] i386: single node SPARSEMEM fix
In-Reply-To: <1126114116.7329.16.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20050906035531.31603.46449.sendpatchset@cherry.local>
	 <1126114116.7329.16.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Magnus Damm <magnus@valinux.co.jp>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "A. P. Whitcroft [imap]" <andyw@uk.ibm.com>
List-ID: <linux-mm.kvack.org>

On 9/8/05, Dave Hansen <haveblue@us.ibm.com> wrote:
> On Tue, 2005-09-06 at 12:56 +0900, Magnus Damm wrote:
> > This patch for 2.6.13-git5 fixes single node sparsemem support. In the case
> > when multiple nodes are used, setup_memory() in arch/i386/mm/discontig.c calls
> > get_memcfg_numa() which calls memory_present(). The single node case with
> > setup_memory() in arch/i386/kernel/setup.c does not call memory_present()
> > without this patch, which breaks single node support.
> 
> First of all, this is really a feature addition, not a bug fix. :)

>From the POV that you can use sparsemem on a PC, yes. But from the POV
that setup_memory() in arch/i386/kernel/setup.c not includes a call to
memory_present(), I think it is a fix. =)

While at it, why do we have two copies of setup_memory()? Couldn't
NUMA and non-NUMA share the same code? OTOH, NUMA and discontigmem
seems very integrated/mixed up and there seems to be much activity in
this field so maybe it is nice to keep the NUMA part separated anyway.
 
> The reason we haven't included this so far is that we don't really have
> any machines that need sparsemem on i386 that aren't NUMA.  So, we
> disabled it for now, and probably need to decide first why we need it
> before a patch like that goes in.

Well, I do not have any hardware here that requires sparsemem either,
but I wanted to add NUMA emulation code to be able to run some
multiple-memory-nodes tests on a virtual PC in QEMU. And this little
patch shows my first step which involved getting sparsememto run on a
PC.

> I actually have exactly the same patch that you sent out in my tree, but
> it's just for testing.  Magnus, perhaps we can get some of my testing
> patches in good enough shape to put them in -mm so that the non-NUMA
> folks can do more sparsemem testing.

Well, my NUMA emulation project has been postponed a bit now, but
sooner or later I or someone else will need sparsemem on non-NUMA. So
getting your testing patches in to -mm seems like a good idea!

Thanks!

/ magnus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
