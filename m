Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 04DC16B005A
	for <linux-mm@kvack.org>; Sat, 24 Oct 2009 09:51:10 -0400 (EDT)
From: Frans Pop <elendil@planet.nl>
Subject: Re: [PATCH 0/5] Candidate fix for increased number of GFP_ATOMIC failures V2
Date: Sat, 24 Oct 2009 15:51:02 +0200
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1256221356-26049-1-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200910241551.08291.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org\"" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thursday 22 October 2009, Mel Gorman wrote:
> Since 2.6.31-rc1, there have been an increasing number of GFP_ATOMIC
> failures. A significant number of these have been high-order GFP_ATOMIC
> failures and while they are generally brushed away, there has been a
> large increase in them recently and there are a number of possible areas
> the problem could be in - core vm, page writeback and a specific driver.

I needed a break and have thus been off-line for a few days. Good to see 
there's been progress. I'll try to do some testing tomorrow.

Cheers,
FJP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
