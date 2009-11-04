Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6BB2A6B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 21:03:07 -0500 (EST)
Received: by bwz7 with SMTP id 7so9013069bwz.6
        for <linux-mm@kvack.org>; Tue, 03 Nov 2009 18:03:05 -0800 (PST)
Date: Wed, 4 Nov 2009 03:03:01 +0100
From: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Subject: Re: [PATCH 0/5] Candidate fix for increased number of GFP_ATOMIC
	failures V2
Message-ID: <20091104020301.GA7037@bizet.domek.prywatny>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <20091023165810.GA4588@bizet.domek.prywatny> <20091023211239.GA6185@bizet.domek.prywatny> <9ec2d7290910240646p75b93c68v6ea1648d628a9660@mail.gmail.com> <20091028114208.GA14476@bizet.domek.prywatny> <20091028115926.GW8900@csn.ul.ie> <20091030142350.GA9343@bizet.domek.prywatny> <20091102203034.GC22046@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091102203034.GC22046@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Karol Lewandowski <karol.k.lewandowski@gmail.com>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 02, 2009 at 08:30:34PM +0000, Mel Gorman wrote:
> Does applying the following on top make any difference?
> 
> ==== CUT HERE ====
> PM: Shrink memory before suspend

No, this patch didn't change anything either.

IIRC I get failures while free(1) shows as much as 20MB free RAM
(ie. without buffers/caches).  Additionaly nr_free_pages (from
/proc/vmstat) stays at about 800-1000 under heavy memory pressure
(gitk on full linux repository).


--- babbling follows ---

Hmm, I wonder if it's really timing issue then wouldn't be the case
that lowering swappiness sysctl would make problem more visible?
I've vm.swappiness=15, would testing with higher value make any sense?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
