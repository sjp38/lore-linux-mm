Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id TAA20342
	for <linux-mm@kvack.org>; Fri, 6 Sep 2002 19:00:30 -0700 (PDT)
Message-ID: <3D7960FC.3E2C890A@digeo.com>
Date: Fri, 06 Sep 2002 19:14:20 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: inactive_dirty list
References: <3D79131E.837F08B3@digeo.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> 
> Rik, it seems that the time has come...
> 
> I was doing some testing overnight with mem=1024m.  Page reclaim
> was pretty inefficient at that level: kswapd consumed 6% of CPU
> on a permanent basis (workload was heavy dbench plus looping
> make -j6 bzImage).  kswapd was reclaiming only 3% of the pages
> which it was looking at.

I have a silly feeling that setting DEF_PRIORITY to "12" will
simply fix this.

Duh.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
