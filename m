Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A0AD26B005A
	for <linux-mm@kvack.org>; Fri, 23 Oct 2009 22:38:13 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E4CE282C772
	for <linux-mm@kvack.org>; Fri, 23 Oct 2009 22:43:38 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id NShRKrpHPeKK for <linux-mm@kvack.org>;
	Fri, 23 Oct 2009 22:43:34 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3D85D82C917
	for <linux-mm@kvack.org>; Fri, 23 Oct 2009 22:43:27 -0400 (EDT)
Date: Fri, 23 Oct 2009 22:03:05 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 2/5] page allocator: Do not allow interrupts to use
 ALLOC_HARDER
In-Reply-To: <20091022163752.GU11778@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0910232201520.9557@V090114053VZO-1>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <1256221356-26049-3-git-send-email-mel@csn.ul.ie> <20091022183303.2448942d.skraw@ithnet.com> <20091022163752.GU11778@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Stephan von Krawczynski <skraw@ithnet.com>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

There are now rt dependencies in the page allocator that screw things up?

And an rt flag causes the page allocator to try harder meaning it adds
latency.

?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
