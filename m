Subject: Re: 2.5.70-mm3: LVM/device-mapper seems broken
References: <20030531013716.07d90773.akpm@digeo.com>
	<6u4r3bky20.fsf@zork.zork.net>
	<1054390711.13115.1.camel@chtephan.cs.pocnet.net>
	<6uznl3jh25.fsf@zork.zork.net>
From: Sean Neakums <sneakums@zork.net>
Date: Sat, 31 May 2003 16:11:33 +0100
In-Reply-To: <6uznl3jh25.fsf@zork.zork.net> (Sean Neakums's message of "Sat,
 31 May 2003 16:01:54 +0100")
Message-ID: <6uvfvrjgm2.fsf@zork.zork.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christophe Saout <christophe@saout.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Sean Neakums <sneakums@zork.net> writes:

> Christophe Saout <christophe@saout.de> writes:
>
>> You need to recompile libdevmapper against the new kernel headers. The
>> kdev_t size has changed and unfortunately the old ioctl interface
>> exposed this limited one to the userspace.
>
> Aha.
>
> The 64-bit device number patch reverses cleanly, so I think I'll just
> build without it and try again.

Okay, that did it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
