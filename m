Date: Mon, 4 Mar 2002 15:04:43 -0600
From: Matt Reppert <matt@nyu.dyn.dhs.org>
Subject: Re: [PATCH] radix-tree pagecache for 2.4.19-pre2-ac2
Message-Id: <20020304150443.393affe9.matt@nyu.dyn.dhs.org>
In-Reply-To: <20020304232510.C333@stingr.net>
References: <20020303210346.A8329@caldera.de>
	<20020304232510.C333@stingr.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: hch@caldera.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 4 Mar 2002 23:25:10 +0300
Paul P Komkoff Jr <i@stingr.net> wrote:

> Replying to Christoph Hellwig:
> > I have uploaded an updated version of the radix-tree pagecache patch
> > against 2.4.19-pre2-ac2.  News in this release:
> 
> 60% the patch is broken. I got 2 oopses. Both looking the same.

I have this same problem, same place (shmem.c line 498). BUG
triggered on calling shmem_writepage. Through interesting
coincidence, I also have had it happen twice. The second time
I noticed that this happened with RAM basically gone, swap
usage at about 20%. I was doing a 'make install'.

2.4.19-pre2-ac2 +rmap12g +preempt,lockbreak +radix tree pagecache
+ a few fixes from 2.4.18-ac3

 - Matt
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
