Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 78A0F6B004F
	for <linux-mm@kvack.org>; Mon, 19 Oct 2009 04:06:59 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C6DC482C2DC
	for <linux-mm@kvack.org>; Mon, 19 Oct 2009 04:11:55 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id n87sKDJfua7v for <linux-mm@kvack.org>;
	Mon, 19 Oct 2009 04:11:51 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 6747982C3B3
	for <linux-mm@kvack.org>; Mon, 19 Oct 2009 04:11:10 -0400 (EDT)
Date: Mon, 19 Oct 2009 03:40:55 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 1/2] page allocator: Always wake kswapd when restarting
 an allocation attempt after direct reclaim failed
In-Reply-To: <1255689446-3858-2-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0910190340310.24325@gentwo.org>
References: <1255689446-3858-1-git-send-email-mel@csn.ul.ie> <1255689446-3858-2-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable <stable@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Frans Pop <elendil@planet.nl>, reinette chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org\"" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>



Reviewed-by: Christoph Lameter <cl@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
