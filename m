Date: Sun, 15 Jul 2001 15:42:19 +1200
From: Chris Wedgwood <cw@f00f.org>
Subject: Re: RFC: Remove swap file support
Message-ID: <20010715154219.C7624@weta.f00f.org>
References: <3B472C06.78A9530C@mandrakesoft.com> <m1elrk3uxh.fsf@frodo.biederman.org> <20010715032528.E6722@weta.f00f.org> <m13d7z4dmv.fsf@frodo.biederman.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m13d7z4dmv.fsf@frodo.biederman.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Jeff Garzik <jgarzik@mandrakesoft.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, viro@math.psu.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 14, 2001 at 11:35:52AM -0600, Eric W. Biederman wrote:

    I can't see how any device that doesn't support read or writing
    just a byte can be a character device.

For requests smaller than the natural block size, you buffer and throw
away... this will surely suck for writing do a hd byte-by-byte though
:)



  --cw
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
