Date: Thu, 28 Jul 2005 11:14:21 -0700
From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: Re: [patch] mm: Ensure proper alignment for node_remap_start_pfn
Message-ID: <20050728181421.GA3842@localhost.localdomain>
References: <20050728004241.GA16073@localhost.localdomain> <20050727181724.36bd28ed.akpm@osdl.org> <20050728013134.GB23923@localhost.localdomain> <1122571226.23386.44.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1122571226.23386.44.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 28, 2005 at 10:20:26AM -0700, Dave Hansen wrote:
> On Wed, 2005-07-27 at 18:31 -0700, Ravikiran G Thirumalai wrote:
> > On Wed, Jul 27, 2005 at 06:17:24PM -0700, Andrew Morton wrote:
> > > Ravikiran G Thirumalai <kiran@scalex86.org> wrote:
> > > >
> > Yes, it does cause a crash.
> 
> I don't know of any NUMA x86 sub-arches that have nodes which are
> aligned on any less than 2MB.  Is this an architecture that's supported
> in the tree, today?

SRAT need not guarantee any alignment at all in the memory affinity 
structure (the address in 64-bit byte address).   And yes, there are x86-numa
machines that run the latest kernel tree and face this problem.

Thanks,
Kiran
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
