Date: Wed, 26 Nov 2003 04:42:51 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.0-test10-mm1
Message-Id: <20031126044251.3b8309c1.akpm@osdl.org>
In-Reply-To: <20031126085123.A1952@infradead.org>
References: <20031125211518.6f656d73.akpm@osdl.org>
	<20031126085123.A1952@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Hellwig <hch@infradead.org> wrote:
>
> On Tue, Nov 25, 2003 at 09:15:18PM -0800, Andrew Morton wrote:
> > +invalidate_mmap_range-non-gpl-export.patch
> > 
> >  Export invalidate_mmap_range() to all modules
> 
> Why?

The individual patches in the broken-out/ directory are usually
changelogged.  This one says:

  It was EXPORT_SYMBOL_GPL(), however IBM's GPFS is not GPL.

  - the GPFS team contributed to the testing and development of
    invaldiate_mmap_range().

  - GPFS was developed under AIX and was ported to Linux, and hence meets
    Linus's "some binary modules are OK" exemption.

  - The export makes sense: clustering filesystems need it for shootdowns to
    ensure cache coherency.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
