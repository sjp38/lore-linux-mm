Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 446286B004F
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 04:08:26 -0400 (EDT)
Date: Wed, 1 Jul 2009 10:08:34 +0200
From: Attila Kinali <attila@kinali.ch>
Subject: Re: Long lasting MM bug when swap is smaller than RAM
Message-Id: <20090701100834.1f740ad5.attila@kinali.ch>
In-Reply-To: <20090701100432.2d328e46.attila@kinali.ch>
References: <20090630115819.38b40ba4.attila@kinali.ch>
	<4A4ABD8F.40907@gmail.com>
	<20090701100432.2d328e46.attila@kinali.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Robert Hancock <hancockrwd@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 1 Jul 2009 10:04:32 +0200
Attila Kinali <attila@kinali.ch> wrote:

> > But 
> > swapping does not only occur if memory is running low. If disk usage is 
> > high then non-recently used data may be swapped out to make more room 
> > for disk caching.
> 
> Hmm..I didn't know this.. thanks!

This was the cause of the problem!

I just restarted svnserv, clamav and bind (the three applications
using most memory) and suddenly swap cleared up.

Now the question is, why did they accumulate so much used swap
space, while before the RAM upgrade, we hardly used the swap space at all?

		Attila Kinali

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
