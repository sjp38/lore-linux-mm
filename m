Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id B15726B006C
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 16:56:10 -0500 (EST)
Date: Tue, 15 Jan 2013 16:56:02 -0500
From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH v2] mm: dmapool: use provided gfp flags for all
 dma_alloc_coherent() calls
Message-ID: <20130115215602.GF25500@titan.lakedaemon.net>
References: <20121119144826.f59667b2.akpm@linux-foundation.org>
 <1353421905-3112-1-git-send-email-m.szyprowski@samsung.com>
 <50F3F289.3090402@web.de>
 <20130115165642.GA25500@titan.lakedaemon.net>
 <20130115175020.GA3764@kroah.com>
 <20130115201617.GC25500@titan.lakedaemon.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130115201617.GC25500@titan.lakedaemon.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Andrew Lunn <andrew@lunn.ch>, Arnd Bergmann <arnd@arndb.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Soeren Moch <smoch@web.de>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linaro-mm-sig@lists.linaro.org, linux-arm-kernel@lists.infradead.org, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

Soeren,

On Tue, Jan 15, 2013 at 03:16:17PM -0500, Jason Cooper wrote:
> If my understanding is correct, one of the drivers (most likely one)
> either asks for too small of a dma buffer, or is not properly
> deallocating blocks from the per-device pool.  Either case leads to
> exhaustion, and falling back to the atomic pool.  Which subsequently
> gets wiped out as well.

If my hunch is right, could you please try each of the three dvb drivers
in turn and see which one (or more than one) causes the error?

thx,

Jason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
