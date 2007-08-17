Date: Fri, 17 Aug 2007 12:23:04 -0400
From: Josef Sipek <jsipek@fsl.cs.sunysb.edu>
Subject: Re: [PATCH 17/23] mm: count reclaimable pages per BDI
Message-ID: <20070817162304.GB27836@filer.fsl.cs.sunysb.edu>
References: <20070816074525.065850000@chello.nl> <20070816074628.776394000@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070816074628.776394000@chello.nl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 16, 2007 at 09:45:42AM +0200, Peter Zijlstra wrote:
...
> Index: linux-2.6/include/linux/backing-dev.h
> ===================================================================
> --- linux-2.6.orig/include/linux/backing-dev.h
> +++ linux-2.6/include/linux/backing-dev.h
> @@ -27,6 +27,7 @@ enum bdi_state {
>  typedef int (congested_fn)(void *, int);
>  
>  enum bdi_stat_item {
> +	BDI_RECLAIMABLE,
>  	NR_BDI_STAT_ITEMS
>  };

Ok, I see. Ignore my comment on 16/xx :)

Jeff.

-- 
Keyboard not found!
Press F1 to enter Setup

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
