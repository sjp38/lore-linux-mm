Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2E9546B004F
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 19:28:34 -0400 (EDT)
From: Frans Pop <elendil@planet.nl>
Subject: Re: [PATCH 2/2] page allocator: Direct reclaim should always obey watermarks
Date: Sat, 17 Oct 2009 01:28:26 +0200
References: <1255689446-3858-1-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.00.0910161204140.21328@chino.kir.corp.google.com> <20091016223237.GE32397@csn.ul.ie>
In-Reply-To: <20091016223237.GE32397@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200910170128.29086.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, stable <stable@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, reinette chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Saturday 17 October 2009, Mel Gorman wrote:
> Frans, you reported that both patches in combination reduced the number
> of failures. Was it in fact just the kswapd change that made the
> difference?

I will retest both patches (as I already mailed you privately yesterday), 
but not today. The improvement with the combination was real, but I'm not 
sure which patch is the reason. I think the second, but I need to verify.

I've done another 30 boots or so today, mainly in the "akpm" merge, and 
I've found new patterns that will help me nail down the regression. But 
ATM I can't see straight anymore, so it will have to wait until tomorrow.

I'd suggest to delay merging any patches for now. There are still too many 
open ends.

Cheers,
FJP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
