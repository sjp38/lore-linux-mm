Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id UAA13716
	for <linux-mm@kvack.org>; Sat, 14 Sep 2002 20:56:36 -0700 (PDT)
Message-ID: <3D8408A9.7B34483D@digeo.com>
Date: Sat, 14 Sep 2002 21:12:25 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.34-mm2
References: <3D803434.F2A58357@digeo.com> <E17qQMq-0001JV-00@starship>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Daniel Phillips wrote:
> 
> On Thursday 12 September 2002 08:29, Andrew Morton wrote:
> > url: http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.34/2.5.34-mm2/
> >
> > -sleeping-release_page.patch
> 
> What's this one?  Couldn't find it as a broken-out patch.

The `-' means it was removed from the patchset.  Linus merged it.
See  2.5.34/2.5.34-mm1/broken-out/sleeping-release_page.patch

> On the nonblocking vm front, does it rule or suck?

It rules, until someone finds something at which it sucks.

>  I heard you
> mention, on the one hand, huge speedups on some load (dbench I think)
> but your in-patch comments mention slowdown by 1.7X on kernel
> compile.

You misread.  Relative times for running `make -j6 bzImage' with mem=512m:

Unloaded system:		                     1.0
2.5.34-mm4, while running 4 x `dbench 100'           1.7
Any other kernel while running 4 x `dbench 100'      basically infinity
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
