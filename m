Date: Mon, 9 Sep 2002 10:10:41 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] modified segq for 2.5
Message-ID: <20020909171041.GF18800@holomorphy.com>
References: <Pine.LNX.4.44L.0208151119190.23404-100000@imladris.surriel.com> <3D7C6C0A.1BBEBB2D@digeo.com> <200209090740.16942.tomlins@cam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <200209090740.16942.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: Andrew Morton <akpm@digeo.com>, Rik van Riel <riel@conectiva.com.br>, sfkaplan@cs.amherst.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 09, 2002 at 07:40:16AM -0400, Ed Tomlinson wrote:
> Second item.  Do you run gkrelmon when doing your tests?  If not please
> install it and watch it slowly start to eat resources.   This morning (uptime 
> Think we have something we can improve here.  I have inclued an strace
> of one (and a bit) update cycle.
> This was with 33-mm5 with your varient of slabasap.

strace -r to get relative timestamps. I've seen some issues where tasks
suck progressively more cpu over time and the box gets unusable, leading
most notably to 30+s or longer fork/exit latencies. Still on idea what's
going wrong when it does, though.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
