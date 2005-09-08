Received: by zproxy.gmail.com with SMTP id v1so1105578nzb
        for <linux-mm@kvack.org>; Wed, 07 Sep 2005 18:51:09 -0700 (PDT)
Message-ID: <aec7e5c305090718515118a7a7@mail.gmail.com>
Date: Thu, 8 Sep 2005 10:51:08 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Reply-To: magnus.damm@gmail.com
Subject: Re: [PATCH] i386: single node SPARSEMEM fix
In-Reply-To: <1126117674.7329.27.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20050906035531.31603.46449.sendpatchset@cherry.local>
	 <1126114116.7329.16.camel@localhost> <512850000.1126117362@flay>
	 <1126117674.7329.27.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: "Martin J. Bligh" <mbligh@mbligh.org>, Magnus Damm <magnus@valinux.co.jp>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "A. P. Whitcroft [imap]" <andyw@uk.ibm.com>
List-ID: <linux-mm.kvack.org>

On 9/8/05, Dave Hansen <haveblue@us.ibm.com> wrote:
> On Wed, 2005-09-07 at 11:22 -0700, Martin J. Bligh wrote:
> > CONFIG_NUMA was meant to (and did at one point) support both NUMA and flat
> > machines. This is essential in order for the distros to support it - same
> > will go for sparsemem.
> 
> That's a different issue.  The current code works if you boot a NUMA=y
> SPARSEMEM=y machine with a single node.  The current Kconfig options
> also enforce that SPARSEMEM depends on NUMA on i386.
> 
> Magnus would like to enable SPARSEMEM=y while CONFIG_NUMA=n.  That
> requires some Kconfig changes, as well as an extra memory present call.
> I'm questioning why we need to do that when we could never do
> DISCONTIG=y while NUMA=n on i386.

Actually, I do not really care about the Kconfig stuff. I just added
that to show you guys why and when the change in
arch/i386/kernel/setup.c was needed. So my main interest is to include
the fix to the single-node version of setup_memory(). This to sync up
the single-node case with the multiple-node version of setup_memory(),
and to make it easier for me and other people to start using sparsemem
om single-node (or non-NUMA if you prefer that) configurations.

/ magnus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
