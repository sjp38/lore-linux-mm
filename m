Date: Fri, 13 Dec 2002 17:55:26 -0500
From: Christoph Hellwig <hch@sgi.com>
Subject: Re: 2.5.50-mm2
Message-ID: <20021213175526.C2581@sgi.com>
References: <3DF453C8.18B24E66@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3DF453C8.18B24E66@digeo.com>; from akpm@digeo.com on Mon, Dec 09, 2002 at 12:26:48AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Dec 09, 2002 at 12:26:48AM -0800, Andrew Morton wrote:
> +remove-PF_SYNC.patch
> 
>  remove the current->flags:PF_SYNC abomination.  Adds a `sync' arg to
>  all writepage implementations to tell them whether they are being
>  called for memory cleansing or for data integrity.

Any chance you could pass down a struct writeback_control instead of
just the sync flag?  XFS always used ->writepage similar to the
->vm_writeback in older kernel releases because writing out more
than one page of delalloc space is really needed to be efficient and
this would allow us to get a few more hints about the VM's intentions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
