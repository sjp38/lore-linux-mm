Date: Wed, 07 Sep 2005 11:34:51 -0700
From: "Martin J. Bligh" <mbligh@mbligh.org>
Reply-To: "Martin J. Bligh" <mbligh@mbligh.org>
Subject: Re: [PATCH] i386: single node SPARSEMEM fix
Message-ID: <521510000.1126118091@flay>
In-Reply-To: <1126117674.7329.27.camel@localhost>
References: <20050906035531.31603.46449.sendpatchset@cherry.local> <1126114116.7329.16.camel@localhost>  <512850000.1126117362@flay> <1126117674.7329.27.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Magnus Damm <magnus@valinux.co.jp>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "A. P. Whitcroft [imap]" <andyw@uk.ibm.com>
List-ID: <linux-mm.kvack.org>


--On Wednesday, September 07, 2005 11:27:54 -0700 Dave Hansen <haveblue@us.ibm.com> wrote:

> On Wed, 2005-09-07 at 11:22 -0700, Martin J. Bligh wrote:
>> CONFIG_NUMA was meant to (and did at one point) support both NUMA and flat
>> machines. This is essential in order for the distros to support it - same
>> will go for sparsemem.
> 
> That's a different issue.  The current code works if you boot a NUMA=y
> SPARSEMEM=y machine with a single node.  The current Kconfig options
> also enforce that SPARSEMEM depends on NUMA on i386.
> 
> Magnus would like to enable SPARSEMEM=y while CONFIG_NUMA=n.  That
> requires some Kconfig changes, as well as an extra memory present call.
> I'm questioning why we need to do that when we could never do
> DISCONTIG=y while NUMA=n on i386.

Ah, OK - makes more sense. However, some machines do have large holes
in e820 map setups - is not really critical, more of an efficiency
thing.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
