Date: Wed, 30 Oct 2002 12:20:10 -0800 (PST)
From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: printk long long
In-Reply-To: <20021030182047.A1690@infradead.org>
Message-ID: <Pine.LNX.4.33L2.0210301211540.18828-100000@dragon.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Hai Huang <haih@eecs.umich.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 30 Oct 2002, Christoph Hellwig wrote:

| On Wed, Oct 30, 2002 at 10:06:01AM -0800, Randy.Dunlap wrote:
| > On Tue, 29 Oct 2002, Hai Huang wrote:
| >
| > | As the title, I've tried couple different things to print a long
| > | long variable using printk (by %ll, %qd, ...) but without success.
| > | Anyone knows the right format?
| >
| > %L
| >
| > see linux/lib/vsprintf.c
|
| %ll is better, as that's what userspace understands, too.

Fair enough.

But he said that he tried "%ll", so maybe he didn't try "%lld"
or "%llx"...?

I was probably just going by what I see most of in the
kernel source tree, which is "%L".

-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
