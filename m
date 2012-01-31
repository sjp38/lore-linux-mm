Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 396236B13F0
	for <linux-mm@kvack.org>; Tue, 31 Jan 2012 05:46:26 -0500 (EST)
Date: Tue, 31 Jan 2012 05:46:21 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] fix readahead pipeline break caused by block plug
Message-ID: <20120131104621.GA27003@infradead.org>
References: <1327996780.21268.42.camel@sli10-conroe>
 <20120131103416.GA1661@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120131103416.GA1661@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <wfg@linux.intel.com>
Cc: Shaohua Li <shaohua.li@intel.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Herbert Poetzl <herbert@13thfloor.at>, Eric Dumazet <eric.dumazet@gmail.com>, Vivek Goyal <vgoyal@redhat.com>

On Tue, Jan 31, 2012 at 06:34:16PM +0800, Wu Fengguang wrote:
>  	}
>  
> +	blk_start_plug(&plug);
>  	written = mapping->a_ops->direct_IO(WRITE, iocb, iov, pos, *nr_segs);
> +	blk_finish_plug(&plug);

Please move the plugging into ->direct_IO for both read and write, as
that is the boundary between generic highlevel code, and low-level block
code that should know about plugs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
