Message-Id: <5.1.1.6.2.20030119090508.00cbd808@pop.gmx.net>
Date: Sun, 19 Jan 2003 09:06:31 +0100
From: Mike Galbraith <efault@gmx.de>
Subject: Re: 2.5.59mm2 BUG at fs/jbd/transaction.c:1148
In-Reply-To: <20030119000548.6a6e26e5.akpm@digeo.com>
References: <5.1.1.6.2.20030119084031.00c81180@pop.gmx.net>
 <20030118002027.2be733c7.akpm@digeo.com>
 <5.1.1.6.2.20030119084031.00c81180@pop.gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

At 12:05 AM 1/19/2003 -0800, Andrew Morton wrote:
>Mike Galbraith <efault@gmx.de> wrote:
> >
> > Greetings,
> >
> > I got the attached oops upon doing my standard reboot sequence SysRq[sub].
> >
> > fwiw, I was fiddling with an ext2 ramdisk just prior to poking buttons.
> >
>
>You using data=journal?

(p.s. it isn't a repeatable oops.  i've done SysRq-S many times)

         -Mike


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
