Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 73DD3600429
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 20:42:16 -0400 (EDT)
Date: Tue, 3 Aug 2010 08:45:11 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Bug 12309 - Large I/O operations result in poor interactive
 performance and high iowait times
Message-ID: <20100803004511.GB5198@localhost>
References: <20100802003616.5b31ed8b@digital-domain.net>
 <20100802081253.GA27492@localhost>
 <20100802171954.4F95.A69D9226@jp.fujitsu.com>
 <20100802115748.GA5308@localhost>
 <AANLkTimPicvVXnfc1qkuWekzmEz18E=t50yhzaxpToae@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTimPicvVXnfc1qkuWekzmEz18E=t50yhzaxpToae@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Clayton <andrew@digital-domain.net>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, "pvz@pvz.pp.se" <pvz@pvz.pp.se>, "bgamari@gmail.com" <bgamari@gmail.com>, "larppaxyz@gmail.com" <larppaxyz@gmail.com>, "seanj@xyke.com" <seanj@xyke.com>, "kernel-bugs.dev1world@spamgourmet.com" <kernel-bugs.dev1world@spamgourmet.com>, "akatopaz@gmail.com" <akatopaz@gmail.com>, "frankrq2009@gmx.com" <frankrq2009@gmx.com>, "thomas.pi@arcor.de" <thomas.pi@arcor.de>, "spawels13@gmail.com" <spawels13@gmail.com>, "vshader@gmail.com" <vshader@gmail.com>, "rockorequin@hotmail.com" <rockorequin@hotmail.com>, "ylalym@gmail.com" <ylalym@gmail.com>, "theholyettlz@googlemail.com" <theholyettlz@googlemail.com>, "hassium@yandex.ru" <hassium@yandex.ru>
List-ID: <linux-mm.kvack.org>

> > What in my mind is (without any throttling)
> >
> > A  A  A  A if (PageSwapcache(page)) {
> > A  A  A  A  A  A  A  A if (bdi_write_congested(bdi))
> 
> You mentioned following as.
> 
> "However !bdi_write_congested(bdi) is now unconditionally true for the
> swapper_space, which means any process can do swap out to a congested
> queue and block there."
> 
> But you used bdi_write_congested in here.
> Which is right?

Ah sorry, I was also cheated by the name.. bdi_write_congested()
won't work for swap_backing_dev_info.  Anyway you may take it as
"pseudo" code :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
