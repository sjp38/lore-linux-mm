Date: Wed, 30 Oct 2002 18:20:47 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: printk long long
Message-ID: <20021030182047.A1690@infradead.org>
References: <Pine.LNX.4.33.0210292118330.1080-100000@wildwood.eecs.umich.edu> <Pine.LNX.4.33L2.0210301005170.18828-100000@dragon.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33L2.0210301005170.18828-100000@dragon.pdx.osdl.net>; from rddunlap@osdl.org on Wed, Oct 30, 2002 at 10:06:01AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Randy.Dunlap" <rddunlap@osdl.org>
Cc: Hai Huang <haih@eecs.umich.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 30, 2002 at 10:06:01AM -0800, Randy.Dunlap wrote:
> On Tue, 29 Oct 2002, Hai Huang wrote:
> 
> | As the title, I've tried couple different things to print a long
> | long variable using printk (by %ll, %qd, ...) but without success.
> | Anyone knows the right format?
> 
> %L
> 
> see linux/lib/vsprintf.c

%ll is better, as that's what userspace understands, too.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
