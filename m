Date: Fri, 18 May 2007 22:32:12 +0200 (MEST)
From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: Re: [patch 10/10] ext2 ext3 ext4: support inode slab defragmentation
In-Reply-To: <20070518181120.938438348@sgi.com>
Message-ID: <Pine.LNX.4.61.0705182229140.9015@yvahk01.tjqt.qr>
References: <20070518181040.465335396@sgi.com> <20070518181120.938438348@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On May 18 2007 11:10, clameter@sgi.com wrote:
>+
>+static struct kmem_cache_ops ext2_kmem_cache_ops = {
>+	ext2_get_inodes,
>+	kick_inodes
>+};
>+

We love C99 names:

static struct kmem_cache_ops ext2_kmem_cache_ops = {
	.get  = ext2_get_inodes,
	.kick = kick_inodes,
};


	Jan
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
