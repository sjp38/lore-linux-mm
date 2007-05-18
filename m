Date: Fri, 18 May 2007 14:03:15 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 10/10] ext2 ext3 ext4: support inode slab defragmentation
In-Reply-To: <Pine.LNX.4.61.0705182229140.9015@yvahk01.tjqt.qr>
Message-ID: <Pine.LNX.4.64.0705181402060.13256@schroedinger.engr.sgi.com>
References: <20070518181040.465335396@sgi.com> <20070518181120.938438348@sgi.com>
 <Pine.LNX.4.61.0705182229140.9015@yvahk01.tjqt.qr>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Engelhardt <jengelh@linux01.gwdg.de>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Fri, 18 May 2007, Jan Engelhardt wrote:

> 
> On May 18 2007 11:10, clameter@sgi.com wrote:
> >+
> >+static struct kmem_cache_ops ext2_kmem_cache_ops = {
> >+	ext2_get_inodes,
> >+	kick_inodes
> >+};
> >+
> 
> We love C99 names:
> 
> static struct kmem_cache_ops ext2_kmem_cache_ops = {
> 	.get  = ext2_get_inodes,
> 	.kick = kick_inodes,
> };
> 

Right. The other patches all have C99 names in kmem_cache_ops. The mass 
handling of extxx filesystems must have made me loose sight of that. Next 
rev will have it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
