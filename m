Date: Thu, 16 Dec 2004 23:06:08 +0000
From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: Re: [patch] [RFC] move 'struct page' into its own header
Message-ID: <20041216230607.B15420@flint.arm.linux.org.uk>
References: <E1Cf3jM-00034h-00@kernel.beaverton.ibm.com> <20041216222513.GA15451@infradead.org> <1103237161.13614.2388.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1103237161.13614.2388.camel@localhost>; from haveblue@us.ibm.com on Thu, Dec 16, 2004 at 02:46:01PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Christoph Hellwig <hch@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 16, 2004 at 02:46:01PM -0800, Dave Hansen wrote:
> But, I'm not quite sure why page-flags.h even needs asm/pgtable.h.  I
> just took it out in i386, and it still compiles just fine.  Maybe it is
> needed for another architecture.

Removing that include is also fine on ARM.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
