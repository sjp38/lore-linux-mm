Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [PATCH] modified segq for 2.5
Date: Tue, 10 Sep 2002 00:46:50 +0200
References: <Pine.LNX.4.44L.0208151119190.23404-100000@imladris.surriel.com> <3D7C6C0A.1BBEBB2D@digeo.com>
In-Reply-To: <3D7C6C0A.1BBEBB2D@digeo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17oXIx-0006vb-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, Rik van Riel <riel@conectiva.com.br>
Cc: William Lee Irwin III <wli@holomorphy.com>, sfkaplan@cs.amherst.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 09 September 2002 11:38, Andrew Morton wrote:
> One thing this patch did do was to speed up the initial untar of
> the kernel source - 50 seconds down to 25.  That'll be due to not
> having so much dirt on the inactive list.  The "nonblocking page
> reclaim" code (needs a better name...)

Nonblocking kswapd, no?  Perhaps 'kscand' would be a better name, now.

> ...does that in 18 secs.

Woohoo!  I didn't think it would make *that* much difference, did you
dig into why?

My reason for wanting nonblocking kswapd has always been to be able to
untangle the multiple-simultaneous-scanners mess, which we are now in
a good position to do.  Erm, it never occurred to me it would be as easy
as checking whether the page *might* block and skipping it if so.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
