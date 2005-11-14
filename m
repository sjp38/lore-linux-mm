Date: Mon, 14 Nov 2005 10:09:26 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [RFC] NUMA memory policy support for HUGE pages
In-Reply-To: <1131980814.13502.12.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.62.0511141007590.353@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0511111051080.20589@schroedinger.engr.sgi.com>
 <Pine.LNX.4.62.0511111225100.21071@schroedinger.engr.sgi.com>
 <1131980814.13502.12.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, ak@suse.de, linux-kernel@vger.kernel.org, kenneth.w.chen@intel.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Mon, 14 Nov 2005, Adam Litke wrote:

> On Fri, 2005-11-11 at 12:28 -0800, Christoph Lameter wrote:
> > I just saw that mm2 is out. This is the same patch against mm2 with 
> > hugetlb COW support.
> 
> This all seems reasonable to me.  Were you planning to send out a
> separate patch to support MPOL_BIND?

MPOL_BIND will provide a zonelist with only the nodes allowed. This is 
included in the way the policy layer builds the zonelists.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
