Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 358BA6B02A3
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 15:15:35 -0400 (EDT)
Date: Thu, 22 Jul 2010 12:14:57 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 0/8] zcache: page cache compression support
Message-ID: <20100722191457.GA13309@kroah.com>
References: <1279283870-18549-1-git-send-email-ngupta@vflare.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1279283870-18549-1-git-send-email-ngupta@vflare.org>
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Christoph Hellwig <hch@infradead.org>, Minchan Kim <minchan.kim@gmail.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 16, 2010 at 06:07:42PM +0530, Nitin Gupta wrote:
> Frequently accessed filesystem data is stored in memory to reduce access to
> (much) slower backing disks. Under memory pressure, these pages are freed and
> when needed again, they have to be read from disks again. When combined working
> set of all running application exceeds amount of physical RAM, we get extereme
> slowdown as reading a page from disk can take time in order of milliseconds.

<snip>

Given that there were a lot of comments and changes for this series, can
you resend them with your updates so I can then apply them if they are
acceptable to everyone?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
