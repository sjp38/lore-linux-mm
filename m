Date: Sun, 2 Feb 2003 11:59:08 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: hugepage patches
Message-ID: <20030202195908.GD29981@holomorphy.com>
References: <20030131151501.7273a9bf.akpm@digeo.com> <20030202025546.2a29db61.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030202025546.2a29db61.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: davem@redhat.com, rohit.seth@intel.com, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Feb 02, 2003 at 02:55:46AM -0800, Andrew Morton wrote:
> 6/4
> hugetlbfs: fix truncate
> - Opening a hugetlbfs file O_TRUNC calls the generic vmtruncate() functions
>   and nukes the kernel.
>   Give S_ISREG hugetlbfs files a inode_operations, and hence a setattr
>   which know how to handle these files.
> - Don't permit the user to truncate hugetlbfs files to sizes which are not
>   a multiple of HPAGE_SIZE.
> - We don't support expanding in ftruncate(), so remove that code.

erm, IIRC ftruncate() was the only way to expand the things; without
read() or write() showing up this creates a huge semantic deficit.
When I wake up the rest of the way I'll eventually remember which
debate I lost that introduced an alternative method.

Leaving .setattr out of the non-directory inode ops and/or not having
a non-directory i_ops is a relatively huge omission. Not sure how
anything actually survived that.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
