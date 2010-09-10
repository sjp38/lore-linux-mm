Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9AB806B009F
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 06:30:15 -0400 (EDT)
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1Ou0rr-00013v-Rr
	for linux-mm@kvack.org; Fri, 10 Sep 2010 12:30:03 +0200
Received: from f053214237.adsl.alicedsl.de ([78.53.214.237])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Fri, 10 Sep 2010 12:30:03 +0200
Received: from florian by f053214237.adsl.alicedsl.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Fri, 10 Sep 2010 12:30:03 +0200
From: Florian Mickler <florian@mickler.org>
Subject: Re: block cache replacement strategy?
Date: Fri, 10 Sep 2010 12:02:35 +0200
Message-ID: <20100910120235.455962c4@schatten.dmk.lab>
References: <20100907133429.GB3430@sig21.net>
	<20100909120044.GA27765@sig21.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
In-Reply-To: <20100909120044.GA27765@sig21.net>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 9 Sep 2010 14:00:44 +0200
Johannes Stezenbach <js@sig21.net> wrote:

> On Tue, Sep 07, 2010 at 03:34:29PM +0200, Johannes Stezenbach wrote:
> > 
> > during some simple disk read throughput testing I observed
> > caching behaviour that doesn't seem right.  The machine
> > has 2G of RAM and AMD Athlon 4850e, x86_64 kernel but 32bit
> > userspace, Linux 2.6.35.4.  It seems that contents of the
> > block cache are not evicted to make room for other blocks.
> > (Or something like that, I have no real clue about this.)
> > 
> > Since this is a rather artificial test I'm not too worried,
> > but it looks strange to me so I thought I better report it.
> 
> C'mon guys, please comment.  Is this a bug or not?
> Or is my question too silly?
> 
> 
> Johannes

Well I personally have  no clue about the block caching, but perhaps
that is an heuristic to prevent the cache from fluctuating too much?
Some minimum time a block is hold... in a big linear read the cache is
useless anyway most of the time, so it could make some sense...

You could try accessing random files after filling up the cache and
check if those evict the the cache.  That should rule out any
linear-read-detection heuristic. 

Cheers,
Flo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
