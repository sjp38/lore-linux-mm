Date: Thu, 9 Aug 2007 12:15:07 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 17/23] mm: count writeback pages per BDI
In-Reply-To: <20070803125237.072937000@chello.nl>
Message-ID: <Pine.LNX.4.64.0708091214330.27092@schroedinger.engr.sgi.com>
References: <20070803123712.987126000@chello.nl> <20070803125237.072937000@chello.nl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, 3 Aug 2007, Peter Zijlstra wrote:

>  						page_index(page),
>  						PAGECACHE_TAG_WRITEBACK);
> +			if (bdi_cap_writeback_dirty(bdi))
> +				__dec_bdi_stat(bdi, BDI_WRITEBACK);

Why are these not incremented and decremented in the exact location of 
NR_WRITEBACK?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
