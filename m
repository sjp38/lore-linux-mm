Received: by zproxy.gmail.com with SMTP id v1so1105088nzb
        for <linux-mm@kvack.org>; Wed, 07 Sep 2005 18:45:38 -0700 (PDT)
Message-ID: <aec7e5c305090718455166714e@mail.gmail.com>
Date: Thu, 8 Sep 2005 10:45:37 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Reply-To: magnus.damm@gmail.com
Subject: Re: [PATCH] i386: single node SPARSEMEM fix
In-Reply-To: <512850000.1126117362@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20050906035531.31603.46449.sendpatchset@cherry.local>
	 <1126114116.7329.16.camel@localhost> <512850000.1126117362@flay>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Dave Hansen <haveblue@us.ibm.com>, Magnus Damm <magnus@valinux.co.jp>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "A. P. Whitcroft [imap]" <andyw@uk.ibm.com>
List-ID: <linux-mm.kvack.org>

On 9/8/05, Martin J. Bligh <mbligh@mbligh.org> wrote:
> --On Wednesday, September 07, 2005 10:28:36 -0700 Dave Hansen <haveblue@us.ibm.com> wrote:
> 
> > On Tue, 2005-09-06 at 12:56 +0900, Magnus Damm wrote:
> >> This patch for 2.6.13-git5 fixes single node sparsemem support. In the case
> >> when multiple nodes are used, setup_memory() in arch/i386/mm/discontig.c calls
> >> get_memcfg_numa() which calls memory_present(). The single node case with
> >> setup_memory() in arch/i386/kernel/setup.c does not call memory_present()
> >> without this patch, which breaks single node support.
> >
> > First of all, this is really a feature addition, not a bug fix. :)
> >
> > The reason we haven't included this so far is that we don't really have
> > any machines that need sparsemem on i386 that aren't NUMA.  So, we
> > disabled it for now, and probably need to decide first why we need it
> > before a patch like that goes in.
> 
> CONFIG_NUMA was meant to (and did at one point) support both NUMA and flat
> machines. This is essential in order for the distros to support it - same
> will go for sparsemem.

Yes, by reading the code this becomes very clear. But what is the
current status? Is CONFIG_X86_GENERICARCH working right out of the box
on 2.6.13?

Thanks!

/ magnus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
