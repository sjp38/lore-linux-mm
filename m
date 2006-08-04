Date: Fri, 4 Aug 2006 09:14:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/2] slab: optimize kmalloc_node the same way as kmalloc
In-Reply-To: <20060804151546.GB29422@lst.de>
Message-ID: <Pine.LNX.4.64.0608040913060.3088@schroedinger.engr.sgi.com>
References: <20060804151546.GB29422@lst.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: akpm@osdl.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 4 Aug 2006, Christoph Hellwig wrote:

> Signed-off-by: Christoph Hellwig <hch@lst.de>

I actually posted almost the same patch a year ago. But note that 
kmalloc_node() does not use cpucaches and therefore does not
have the speed of kmalloc()

Acked-by: Christoph Lameter <clameter@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
