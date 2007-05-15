Date: Tue, 15 May 2007 10:09:07 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/2] Have kswapd keep a minimum order free other than
 order-0
In-Reply-To: <1179218576.25205.1.camel@rousalka.dyndns.org>
Message-ID: <Pine.LNX.4.64.0705151008120.31624@schroedinger.engr.sgi.com>
References: <20070514173218.6787.56089.sendpatchset@skynet.skynet.ie>
 <20070514173238.6787.57003.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0705141058590.11319@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0705141111400.11411@schroedinger.engr.sgi.com>
 <20070514182456.GA9006@skynet.ie> <1179218576.25205.1.camel@rousalka.dyndns.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nicolas Mailhot <nicolas.mailhot@laposte.net>
Cc: Mel Gorman <mel@skynet.ie>, apw@shadowen.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 May 2007, Nicolas Mailhot wrote:

> Kernel with this patch and the other one survives testing. I'll stop
> heavy testing now and consider the issue closed.
> 
> Thanks for looking at my bug report.

Wow! This really works Mel! So I can start the work on merging the large 
buffer size / variable order page cache next? This is going to put some 
more pressure on the antifrag patchset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
