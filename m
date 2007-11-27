Date: Tue, 27 Nov 2007 08:36:41 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH][SHMEM] Factor out sbi->free_inodes manipulations
In-Reply-To: <20071126212311.88818502.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0711270835170.19731@blonde.wat.veritas.com>
References: <4745B4F2.3060308@openvz.org> <Pine.LNX.4.64.0711231325510.18348@blonde.wat.veritas.com>
 <20071126212311.88818502.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pavel Emelyanov <xemul@openvz.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, devel@openvz.org
List-ID: <linux-mm.kvack.org>

On Mon, 26 Nov 2007, Andrew Morton wrote:
> 
> It is peculair to (wrongly) return -ENOMEM
> 
> > +	if (shmem_reserve_inode(inode->i_sb))
> > +		return -ENOSPC;
> 
> and to then correct it in the caller..

Oops, I missed that completely.

> Something boringly conventional such as the below, perhaps?

Much better, thanks.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
