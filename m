Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: 2.5.34-mm2
Date: Sun, 15 Sep 2002 06:23:51 +0200
References: <3D803434.F2A58357@digeo.com> <E17qQMq-0001JV-00@starship> <3D8408A9.7B34483D@digeo.com>
In-Reply-To: <3D8408A9.7B34483D@digeo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17qQwq-0001qT-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sunday 15 September 2002 06:12, Andrew Morton wrote:
> Daniel Phillips wrote:
> >  I heard you
> > mention, on the one hand, huge speedups on some load (dbench I think)
> > but your in-patch comments mention slowdown by 1.7X on kernel
> > compile.
> 
> You misread.  Relative times for running `make -j6 bzImage' with mem=512m:
> 
> Unloaded system:		                     1.0
> 2.5.34-mm4, while running 4 x `dbench 100'           1.7
> Any other kernel while running 4 x `dbench 100'      basically infinity

Oh good :-)

We can make the rescanning go away in time, with more lru lists, but
that sure looks like the low hanging fruit.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
