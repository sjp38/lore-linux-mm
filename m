Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id AAA00457
	for <linux-mm@kvack.org>; Sun, 19 Jan 2003 00:56:02 -0800 (PST)
Date: Sun, 19 Jan 2003 00:57:37 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.59mm2 BUG at fs/jbd/transaction.c:1148
Message-Id: <20030119005737.5d0b8a7e.akpm@digeo.com>
In-Reply-To: <5.1.1.6.2.20030119090404.00c82030@pop.gmx.net>
References: <5.1.1.6.2.20030119084031.00c81180@pop.gmx.net>
	<20030118002027.2be733c7.akpm@digeo.com>
	<5.1.1.6.2.20030119084031.00c81180@pop.gmx.net>
	<5.1.1.6.2.20030119090404.00c82030@pop.gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <efault@gmx.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mike Galbraith <efault@gmx.de> wrote:
>
> At 12:05 AM 1/19/2003 -0800, Andrew Morton wrote:
> >Mike Galbraith <efault@gmx.de> wrote:
> > >
> > > Greetings,
> > >
> > > I got the attached oops upon doing my standard reboot sequence SysRq[sub].
> > >
> > > fwiw, I was fiddling with an ext2 ramdisk just prior to poking buttons.
> > >
> >
> >You using data=journal?
> 

data=journal is sick in 2.5, although this is not the crash which I have seen
it exhibit.

On my todo list.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
