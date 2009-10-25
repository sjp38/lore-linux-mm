Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id AABAB6B004D
	for <linux-mm@kvack.org>; Sun, 25 Oct 2009 08:57:12 -0400 (EDT)
Date: Sun, 25 Oct 2009 13:57:06 +0100
From: Stephan von Krawczynski <skraw@ithnet.com>
Subject: Re: [PATCH 2/5] page allocator: Do not allow interrupts to use
 ALLOC_HARDER
Message-Id: <20091025135706.8c3d24a7.skraw@ithnet.com>
In-Reply-To: <20091022163752.GU11778@csn.ul.ie>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie>
	<1256221356-26049-3-git-send-email-mel@csn.ul.ie>
	<20091022183303.2448942d.skraw@ithnet.com>
	<20091022163752.GU11778@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 22 Oct 2009 17:37:52 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> In this case, it's ok. It's just a harmless heads-up that the kernel
> looks slightly different than expected. I posted a 2.6.31.4 version of
> the two patches that cause real problems.

After around 12 hours of runtime with patch 1/5 and 2/5 on 2.6.31.4 I can see
no page allocation failure messages so far. I'll keep you informed.

[Update]
After 2 days I still see no failure messages. 
[/update]

-- 
Regards,
Stephan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
