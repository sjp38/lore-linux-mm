Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: 2.5.34-mm2
Date: Sun, 15 Sep 2002 19:08:24 +0200
References: <3D841C8A.682E6A5C@digeo.com> <Pine.LNX.4.44L.0209151156080.1857-100000@imladris.surriel.com> <3D84BFC8.2D8A7592@digeo.com>
In-Reply-To: <3D84BFC8.2D8A7592@digeo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17qcsi-0000DE-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, Rik van Riel <riel@conectiva.com.br>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sunday 15 September 2002 19:13, Andrew Morton wrote:
> Yes, I'm not particularly fussed about (moderate) excess CPU use in these
> situations, and nor about page replacement accuracy, really - pages
> are being slushed through the system so fast that correct aging of the
> ones on the inactive list probably just doesn't count.

What you really mean is, it hasn't gotten to the top of the list
of things that suck.  When we do get around to fashioning a really
effective page ager (LRU-er, more likely) the further improvement
will be obvious, especially under heavy streaming IO load, which
is getting more important all the time.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
