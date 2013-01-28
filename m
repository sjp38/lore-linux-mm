Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 0ECCB6B0007
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 18:21:47 -0500 (EST)
Date: Tue, 29 Jan 2013 08:21:45 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RESEND PATCH v5 1/4] zram: Fix deadlock bug in partial write
Message-ID: <20130128232145.GA2666@blaptop>
References: <1359333506-13599-1-git-send-email-minchan@kernel.org>
 <CAOJsxLFg_5uhZsvPmVVC0nnsZLGpkJ0W6mHa=aavmguLGuTTnA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOJsxLFg_5uhZsvPmVVC0nnsZLGpkJ0W6mHa=aavmguLGuTTnA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, stable@vger.kernel.org, Jerome Marchand <jmarchan@redhat.com>

On Mon, Jan 28, 2013 at 09:16:35AM +0200, Pekka Enberg wrote:
> On Mon, Jan 28, 2013 at 2:38 AM, Minchan Kim <minchan@kernel.org> wrote:
> > Now zram allocates new page with GFP_KERNEL in zram I/O path
> > if IO is partial. Unfortunately, It may cuase deadlock with
> 
> s/cuase/cause/g

Thanks!

> 
> > reclaim path so this patch solves the problem.
> 
> It'd be nice to know about the problem in more detail. I'm also
> curious on why you decided on GFP_ATOMIC for the read path and
> GFP_NOIO in the write path.

In read path, we called kmap_atomic.

How about this?
------------------------- >8 -------------------------------
