Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA26848
	for <linux-mm@kvack.org>; Wed, 16 Dec 1998 18:01:55 -0500
Date: Wed, 16 Dec 1998 23:38:17 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: mmap() is slower than read() on SCSI/IDE on 2.0 and 2.1 
In-Reply-To: <199812160115.CAA25065@max.phys.uu.nl>
Message-ID: <Pine.LNX.4.03.9812162334170.5325-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Jay Nordwick <nordwick@scam.XCF.Berkeley.EDU>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

(CC:d to Linux-MM to have the last paragraph on record)

On Tue, 15 Dec 1998, Jay Nordwick wrote:

> >And it's not needed at all. We can see if the program is
> >doing sequential reading by simply testing for the presence
> >of pages in the proximity of the faulting address. If there
> >are a lot of pages present behind the current address then
> >we should do read-ahead. With pages in front of us we want
> >read-behind and with no pages or an 'equal' distribution
> >we want a little bit of both read-ahead and read-behind...
> 
> It is needed for hints that you cannot give any other way
> (such as MADV_FREE, MADV_WILLNEED, MADV_DONTNEED).  But as
> the discussion progesses I do see less and less of a need.  I
> can see how it can be called a hack as a VM systems that
> learns from page fault histories better can obviate it.

Since we don't really use page aging anymore, the FREE, WILLNEED
and DONTNEED won't make that much of an impact on performance.

I'm sure they can actually make 25% difference in some borderline
cases, but in RL it'll be pretty marginal -- so marginal that we
don't want the extra code in the kernel...

All the pretty code is better spent on very very good readahead/
readbehind algorithms -- memory is plentyful, disk throughput is
great. We don't have the serious memory shortages that plagued
every system 5 or 10 years ago -- today disk seek time is our big
enemy...

cheers,

Rik -- the flu hits, the flu hits, the flu hits -- MORE
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
