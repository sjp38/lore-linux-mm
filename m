Date: Mon, 18 Nov 2002 10:29:20 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Page size andFS blocksize
Message-ID: <20021118102920.B2928@redhat.com>
References: <20021117070320.75710.qmail@web12305.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20021117070320.75710.qmail@web12305.mail.yahoo.com>; from kravi26@yahoo.com on Sat, Nov 16, 2002 at 11:03:20PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ravi <kravi26@yahoo.com>
Cc: kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, Nov 16, 2002 at 11:03:20PM -0800, Ravi wrote:

>  I was browsing the block device read/write code in fs/buffer.c (kernel
> version 2.4.18).
> >From waht I understood,  there is an implicit assumption that
> filesystem block sizes
> are never more than the size of a single page.

Correct.

> And has this
> changed in
> 2.5?

No.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
