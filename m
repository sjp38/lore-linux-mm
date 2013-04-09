Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 414B96B0027
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 15:54:25 -0400 (EDT)
Date: Tue, 9 Apr 2013 12:54:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: remove compressed copy from zram in-memory
Message-Id: <20130409125423.19592f11e44345df2bca6cfd@linux-foundation.org>
In-Reply-To: <20130409010231.GA3467@blaptop>
References: <1365400862-9041-1-git-send-email-minchan@kernel.org>
	<20130408141710.1a1f76a0054bba49a42c76ca@linux-foundation.org>
	<20130409010231.GA3467@blaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Shaohua Li <shli@kernel.org>, Dan Magenheimer <dan.magenheimer@oracle.com>

On Tue, 9 Apr 2013 10:02:31 +0900 Minchan Kim <minchan@kernel.org> wrote:

> > Also, what's up with the SWP_BLKDEV test?  zram doesn't support
> > SWP_FILE?  Why on earth not?
> > 
> > Putting swap_slot_free_notify() into block_device_operations seems
> > rather wrong.  It precludes zram-over-swapfiles for all time and means
> > that other subsystems cannot get notifications for swap slot freeing
> > for swapfile-backed swap.
> 
> Zram is just pseudo-block device so anyone can format it with any FSes
> and swapon a file. In such case, he can't get a benefit from
> swap_slot_free_notify. But I think it's not a severe problem because
> there is no reason to use a file-swap on zram. If anyone want to use it,
> I'd like to know the reason. If it's reasonable, we have to rethink a
> wheel and it's another story, IMHO.

My point is that making the swap_slot_free_notify() callback a
blockdev-specific thing was restrictive.  What happens if someone wants
to use it for swapfile-backed swap?  This has nothing to do with zram.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
