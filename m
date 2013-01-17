Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 0949E6B005D
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 05:50:18 -0500 (EST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2] mm: dmapool: use provided gfp flags for all dma_alloc_coherent() calls
Date: Thu, 17 Jan 2013 10:49:30 +0000
References: <20121119144826.f59667b2.akpm@linux-foundation.org> <20130116024014.GH25500@titan.lakedaemon.net> <50F61D86.4020801@web.de>
In-Reply-To: <50F61D86.4020801@web.de>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201301171049.30415.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Soeren Moch <smoch@web.de>
Cc: Jason Cooper <jason@lakedaemon.net>, Greg KH <gregkh@linuxfoundation.org>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Andrew Lunn <andrew@lunn.ch>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linaro-mm-sig@lists.linaro.org, linux-arm-kernel@lists.infradead.org, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

On Wednesday 16 January 2013, Soeren Moch wrote:
> >> I will see what I can do here. Is there an easy way to track the buffer
> >> usage without having to wait for complete exhaustion?
> >
> > DMA_API_DEBUG
> 
> OK, maybe I can try this.
> >

Any success with this? It should at least tell you if there is a
memory leak in one of the drivers.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
