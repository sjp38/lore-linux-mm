Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 06F3C6B002C
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 04:18:15 -0500 (EST)
Date: Wed, 1 Feb 2012 04:18:07 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] fix readahead pipeline break caused by block plug
Message-ID: <20120201091807.GA7451@infradead.org>
References: <1327996780.21268.42.camel@sli10-conroe>
 <20120131220333.GD4378@redhat.com>
 <20120131141301.ba35ffe0.akpm@linux-foundation.org>
 <20120131222217.GE4378@redhat.com>
 <20120201033653.GA12092@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120201033653.GA12092@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>, Herbert Poetzl <herbert@13thfloor.at>, Eric Dumazet <eric.dumazet@gmail.com>, Wu Fengguang <wfg@linux.intel.com>

On Tue, Jan 31, 2012 at 10:36:53PM -0500, Vivek Goyal wrote:
> I still see that IO is being submitted one page at a time. The only
> real difference seems to be that queue unplug happening at random times
> and many a times we are submitting much smaller requests (40 sectors, 48
> sectors etc).

This is expected given that the block device node uses
block_read_full_page, and not mpage_readpage(s).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
