Message-ID: <20021118235409.85266.qmail@web12303.mail.yahoo.com>
Date: Mon, 18 Nov 2002 15:54:09 -0800 (PST)
From: Ravi <kravi26@yahoo.com>
Subject: Re: Page size andFS blocksize
In-Reply-To: <20021118102920.B2928@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > I was browsing the block device read/write code 
> > in fs/buffer.c (kernel version 2.4.18).
> > From waht I understood,  there is an implicit
> > assumption that filesystem block sizes
> > are never more than the size of a single page.
> 
> Correct.

 Why is this so? Is it because filesystems cannot
read/write parts of a block? Or is it just that
there is no use for such a feature?

-Thanks,
 Ravi.

__________________________________________________
Do you Yahoo!?
Yahoo! Web Hosting - Let the expert host your site
http://webhosting.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
