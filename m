Date: Sun, 2 Apr 2006 04:24:14 +1000
From: David Chinner <dgc@sgi.com>
Subject: Re: Avoid excessive time spend on concurrent slab shrinking
Message-ID: <20060401182414.GX27189130@melbourne.sgi.com>
References: <Pine.LNX.4.64.0603311441400.8465@schroedinger.engr.sgi.com> <20060331150120.21fad488.akpm@osdl.org> <Pine.LNX.4.64.0603311507130.8617@schroedinger.engr.sgi.com> <20060331153235.754deb0c.akpm@osdl.org> <Pine.LNX.4.64.0603311541260.8948@schroedinger.engr.sgi.com> <20060331160032.6e437226.akpm@osdl.org> <Pine.LNX.4.64.0603311619590.9173@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0603311619590.9173@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 31, 2006 at 04:22:29PM -0800, Christoph Lameter wrote:
> Some traces:
> 
>    Stack traceback for pid 16836
>         0xe00000380bc68000    16836        1  1    6   R  
>         0xa00000020b8e6050 [xfs]xfs_iextract+0x190
>         0xa00000020b8e63a0 [xfs]xfs_ireclaim+0x80
>         0xa00000020b921c70 [xfs]xfs_finish_reclaim+0x330
>         0xa00000020b921fa0 [xfs]xfs_reclaim+0x140
>         0xa00000020b93f820 [xfs]linvfs_clear_inode+0x260

Christoph, what machine, what XFS mount options? Did the latest upgrade
lose the "ihashsize=xxxxx" mount option that used to be set on all
the large filesystems?

Cheers,

Dave.
-- 
Dave Chinner
R&D Software Enginner
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
