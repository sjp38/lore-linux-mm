Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 906F76B003C
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 08:55:15 -0400 (EDT)
Date: Mon, 24 Jun 2013 05:55:13 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC PATCH] vfs: export lseek_execute() to modules
Message-ID: <20130624125513.GA7921@infradead.org>
References: <51C832F8.2090707@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51C832F8.2090707@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jun 24, 2013 at 07:52:24PM +0800, Jeff Liu wrote:
> From: Jie Liu <jeff.liu@oracle.com>
> 
> For those file systems(btrfs/ext4/xfs/ocfs2/tmpfs) that support
> SEEK_DATA/SEEK_HOLE functions, we end up handling the similar
> matter in lseek_execute() to verify the final offset.
> 
> To reduce the duplications, this patch make lseek_execute() public
> accessible so that we can call it directly from them.
> 
> Thanks Dave Chinner for this suggestion.

Please add a kerneldoc comment explaining the use of this function.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
