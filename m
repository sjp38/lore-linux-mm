Message-ID: <45CEA5CC.9090302@redhat.com>
Date: Sun, 11 Feb 2007 00:12:44 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Drop PageReclaim()
References: <Pine.LNX.4.64.0702070612010.14171@schroedinger.engr.sgi.com>	<Pine.LNX.4.64.0702071428590.30412@blonde.wat.veritas.com>	<Pine.LNX.4.64.0702081319530.12048@schroedinger.engr.sgi.com>	<Pine.LNX.4.64.0702081331290.12167@schroedinger.engr.sgi.com>	<Pine.LNX.4.64.0702081340380.13255@schroedinger.engr.sgi.com>	<Pine.LNX.4.64.0702081351270.14036@schroedinger.engr.sgi.com>	<20070208140338.971b3f53.akpm@linux-foundation.org>	<Pine.LNX.4.64.0702081411030.14424@schroedinger.engr.sgi.com>	<20070208142431.eb81ae70.akpm@linux-foundation.org>	<Pine.LNX.4.64.0702081425000.14424@schroedinger.engr.sgi.com>	<20070208143746.79c000f5.akpm@linux-foundation.org>	<Pine.LNX.4.64.0702081438510.15063@schroedinger.engr.sgi.com>	<20070208151341.7e27ca59.akpm@linux-foundation.org>	<Pine.LNX.4.64.0702081613300.15669@schroedinger.engr.sgi.com> <20070208163953.ab2bd694.akpm@linux-foundation.org>
In-Reply-To: <20070208163953.ab2bd694.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

> Well.  IO.  People still seem to thing that vmscan.c is about page
> replacement.  It ain't.  Most of the problems in there and most of the work
> which has gone into it are IO-related.

It's about both.  VM researchers should take note of Andrew's
comment though - page replacement algorithms need to take IO
into account before they can be implemented practically.

For example, any clock-like algorithm will need something to
prevent the VM from starting writeout on way too much memory
at once, as well as something to make it easy to find the
pages that were dirty when last seen by pageout, but just
became easily freeable...

Part of the reason I'm writing this down is so I won't forget
it, but it is also for others.  The development on vmscan.c
has usually been reactive - fix problems as we run into them -
with little understanding of the overall picture.

This is very different from eg. filesystems or networking,
where a lot of things get designed up-front, and it is a
miracle that the VM in the 2.6 kernel works as well as it
does.

I do not believe we can continue this way though.  With
very large memory systems becoming more and more common
and the speed gap between RAM and disk growing we'll have
to figure out the big picture one of these days, or at
least have a checklist of dos and don'ts that anybody
writing a VM patch can check against before submission :)

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
