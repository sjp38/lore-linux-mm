Date: Wed, 26 Nov 2003 13:09:36 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: 2.6.0-test10-mm1
Message-ID: <20031126130936.A5275@infradead.org>
References: <20031125211518.6f656d73.akpm@osdl.org> <20031126085123.A1952@infradead.org> <20031126044251.3b8309c1.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20031126044251.3b8309c1.akpm@osdl.org>; from akpm@osdl.org on Wed, Nov 26, 2003 at 04:42:51AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 26, 2003 at 04:42:51AM -0800, Andrew Morton wrote:
> The individual patches in the broken-out/ directory are usually
> changelogged.  This one says:
> 
>   It was EXPORT_SYMBOL_GPL(), however IBM's GPFS is not GPL.
> 
>   - the GPFS team contributed to the testing and development of
>     invaldiate_mmap_range().
> 
>   - GPFS was developed under AIX and was ported to Linux, and hence meets
>     Linus's "some binary modules are OK" exemption.
> 
>   - The export makes sense: clustering filesystems need it for shootdowns to
>     ensure cache coherency.

Have you actually looked at the gpfs glue code? something that digs that deep
into the VM and VFS actually _must_ be derived work.  Or do wed allow people
now to pay a developer tax to buy themselves free from GPL restrictions.

I as one of the collective copytight holders of the kernel strongly disagree
with that, it can't be true that IBM can just ignore copyright law..
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
