Date: Sun, 15 Jul 2001 03:25:28 +1200
From: Chris Wedgwood <cw@f00f.org>
Subject: Re: RFC: Remove swap file support
Message-ID: <20010715032528.E6722@weta.f00f.org>
References: <3B472C06.78A9530C@mandrakesoft.com> <m1elrk3uxh.fsf@frodo.biederman.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m1elrk3uxh.fsf@frodo.biederman.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Jeff Garzik <jgarzik@mandrakesoft.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, viro@math.psu.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 14, 2001 at 12:07:38AM -0600, Eric W. Biederman wrote:

    Yes, and no.  I'd say what we need to do is update rw_swap_page to
    use the address space functions directly.  With block devices and
    files going through the page cache in 2.5 that should remove any
    special cases cleanly.

Will block devices go through the page cache in 2.5.x?

I had hoped they would, that any block devices would just be
page-cache views of underlying character devices, thus allowing us to
remove the buffer-cache and the /dev/raw stuff.



  --cw
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
