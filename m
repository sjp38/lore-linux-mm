Subject: Re: RFC: Remove swap file support
References: <3B472C06.78A9530C@mandrakesoft.com>
	<m1elrk3uxh.fsf@frodo.biederman.org>
	<20010715032528.E6722@weta.f00f.org>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 14 Jul 2001 11:35:52 -0600
In-Reply-To: <20010715032528.E6722@weta.f00f.org>
Message-ID: <m13d7z4dmv.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Wedgwood <cw@f00f.org>
Cc: Jeff Garzik <jgarzik@mandrakesoft.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, viro@math.psu.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Chris Wedgwood <cw@f00f.org> writes:

> On Sat, Jul 14, 2001 at 12:07:38AM -0600, Eric W. Biederman wrote:
> 
>     Yes, and no.  I'd say what we need to do is update rw_swap_page to
>     use the address space functions directly.  With block devices and
>     files going through the page cache in 2.5 that should remove any
>     special cases cleanly.
> 
> Will block devices go through the page cache in 2.5.x?
> 
> I had hoped they would, that any block devices would just be
> page-cache views of underlying character devices, thus allowing us to
> remove the buffer-cache and the /dev/raw stuff.

<orcale>
Block devices will go through the page cache in 2.5.  It will take a
while for the buffer cache to go away completely, but it is there for
the code paths that haven't been updated.  Buffer heads will stay.

The /dev/raw stuff is for those users that don't want to the kernel to
cache their data and will continue to exist in some form.
</oracle>

I can't see how any device that doesn't support read or writing just a
byte can be a character device.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
