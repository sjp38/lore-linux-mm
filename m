Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2BA556B004D
	for <linux-mm@kvack.org>; Fri, 23 Oct 2009 17:12:46 -0400 (EDT)
Received: by bwz7 with SMTP id 7so1336029bwz.6
        for <linux-mm@kvack.org>; Fri, 23 Oct 2009 14:12:44 -0700 (PDT)
Date: Fri, 23 Oct 2009 23:12:39 +0200
From: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Subject: Re: [PATCH 0/5] Candidate fix for increased number of GFP_ATOMIC
	failures V2
Message-ID: <20091023211239.GA6185@bizet.domek.prywatny>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <20091023165810.GA4588@bizet.domek.prywatny>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091023165810.GA4588@bizet.domek.prywatny>
Sender: owner-linux-mm@kvack.org
To: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 23, 2009 at 06:58:10PM +0200, Karol Lewandowski wrote:
> On Thu, Oct 22, 2009 at 03:22:31PM +0100, Mel Gorman wrote:
> > Test 3: If you are getting allocation failures, try with the following patch
> > 
> >   3/5 vmscan: Force kswapd to take notice faster when high-order watermarks are being hit

> No, problem doesn't go away with these patches (1+2+3).  However, from
> my testing this particular patch makes it way, way harder to trigger
> allocation failures (but these are still present).
> 
> This bothers me - should I test following patches with or without
> above patch?  This patch makes bug harder to find, IMVHO it doesn't
> fix the real problem.
..

> Test 4: If you are still getting failures, apply the following
>  4/5 page allocator: Pre-emptively wake kswapd when high-order watermarks are hit

Ok, I've tested patches 1+2+4 and bug, while very hard to trigger, is
still present. I'll test complete 1-4 patchset as time permits.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
