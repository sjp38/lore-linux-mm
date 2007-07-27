Date: Fri, 27 Jul 2007 09:54:41 +0100
From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans for 2.6.23]
Message-ID: <20070727085440.GT27237@ftp.linux.org.uk>
References: <46A85D95.509@kingswood-consulting.co.uk> <20070726092025.GA9157@elte.hu> <20070726023401.f6a2fbdf.akpm@linux-foundation.org> <20070726094024.GA15583@elte.hu> <20070726030902.02f5eab0.akpm@linux-foundation.org> <1185454019.6449.12.camel@Homer.simpson.net> <20070726110549.da3a7a0d.akpm@linux-foundation.org> <1185513177.6295.21.camel@Homer.simpson.net> <1185521021.6295.50.camel@Homer.simpson.net> <20070727014749.85370e77.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070727014749.85370e77.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 27, 2007 at 01:47:49AM -0700, Andrew Morton wrote:
> What I think is killing us here is the blockdev pagecache: the pagecache
> which backs those directory entries and inodes.  These pages get read
> multiple times because they hold multiple directory entries and multiple
> inodes.  These multiple touches will put those pages onto the active list
> so they stick around for a long time and everything else gets evicted.

I wonder what happens if you try that on ext2.  There we'd get directory
contents in per-directory page cache, so the picture might change...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
