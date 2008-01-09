Date: Wed, 9 Jan 2008 22:01:09 +0100
From: "Klaus S. Madsen" <ksm@42.dk>
Subject: Re: [PATCH][RFC][BUG] updating the ctime and mtime time stamps in msync()
Message-ID: <20080109210108.GB27738@hjernemadsen.org>
References: <1199728459.26463.11.camel@codedot> <20080109155015.4d2d4c1d@cuia.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080109155015.4d2d4c1d@cuia.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Anton Salikhmetov <salikhmetov@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 09, 2008 at 15:50:15 -0500, Rik van Riel wrote:
> > Specifically, the ctime and mtime time stamps do change
> > when modifying the mapped memory and do not change when
> > there have been no write references between the mmap()
> > and msync() system calls.
> 
> As long as the ctime and mtime stamps change when the memory is
> written to, what exactly is the problem?

A "not" is missing from the sentence above. The quote above should have
read:

> > Specifically, the ctime and mtime time stamps do _not_ change when
> > modifying the mapped memory and do not change when there have been
> > no write references between the mmap() and msync() system calls.

So essentially the problem is that mtime stamps are _never_ changed when
the file is only modified through mmap. Not even when calling msync().

-- 
Kind regards,
	Klaus S. Madsen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
