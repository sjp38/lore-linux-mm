Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 401116B009D
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 08:22:02 -0500 (EST)
Received: by ewy24 with SMTP id 24so869415ewy.6
        for <linux-mm@kvack.org>; Thu, 26 Nov 2009 05:21:59 -0800 (PST)
From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: Re: [PATCH-RFC] cfq: Disable low_latency by default for 2.6.32
Date: Thu, 26 Nov 2009 14:20:57 +0100
References: <20091126121945.GB13095@csn.ul.ie> <1259240937.7371.15.camel@marge.simson.net>
In-Reply-To: <1259240937.7371.15.camel@marge.simson.net>
MIME-Version: 1.0
Message-Id: <200911261420.57121.bzolnier@gmail.com>
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mike Galbraith <efault@gmx.de>
Cc: Mel Gorman <mel@csn.ul.ie>, Jens Axboe <jens.axboe@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 26 November 2009 02:08:57 pm Mike Galbraith wrote:
> On Thu, 2009-11-26 at 12:19 +0000, Mel Gorman wrote:
> > (cc'ing the people from the page allocator failure thread as this might be
> > relevant to some of their problems)
> > 
> > I know this is very last minute but I believe we should consider disabling
> > the "low_latency" tunable for block devices by default for 2.6.32.  There was
> > evidence that low_latency was a problem last week for page allocation failure
> > reports but the reproduction-case was unusual and involved high-order atomic
> > allocations in low-memory conditions. It took another few days to accurately
> > show the problem for more normal workloads and it's a bit more wide-spread
> > than just allocation failures.
> > 
> > Basically, low_latency looks great as long as you have plenty of memory
> > but in low memory situations, it appears to cause problems that manifest
> > as reduced performance, desktop stalls and in some cases, page allocation
> > failures. I think most kernel developers are not seeing the problem as they
> > tend to test on beefier machines and without hitting swap or low-memory
> > situations for the most part. When they are hitting low-memory situations,
> > it tends to be for stress tests where stalls and low performance are expected.
> 
> Ouch.  It was bad desktop stalls under heavy write that kicked the whole
> thing off.

The problem is that 'desktop' means different things for different people
(for some kernel developers 'desktop' is more like 'a workstation' and for
others it is more like 'an embedded device').

--
Bartlomiej Zolnierkiewicz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
