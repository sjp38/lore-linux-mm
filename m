Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 345806B0005
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 09:44:57 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id r135so188306819vkf.0
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 06:44:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o13si1817143qko.135.2016.07.11.06.44.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jul 2016 06:44:56 -0700 (PDT)
Date: Mon, 11 Jul 2016 09:44:54 -0400
From: Mike Snitzer <snitzer@redhat.com>
Subject: Re: [4.7.0rc6] Page Allocation Failures with dm-crypt
Message-ID: <20160711134454.GA28370@redhat.com>
References: <28dc911645dce0b5741c369dd7650099@mail.ud19.udmedia.de>
 <e7af885e08e1ced4f75313bfdfda166d@mail.ud19.udmedia.de>
 <20160711131818.GA28102@redhat.com>
 <fe0eb105b21013453bc3375e7026925b@mail.ud19.udmedia.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fe0eb105b21013453bc3375e7026925b@mail.ud19.udmedia.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Dahl <ml_linux-kernel@binary-island.eu>
Cc: linux-mm@kvack.org, dm-devel@redhat.com, linux-kernel@vger.kernel.org

On Mon, Jul 11 2016 at  9:27am -0400,
Matthias Dahl <ml_linux-kernel@binary-island.eu> wrote:

> Hello Mike...
> 
> On 2016-07-11 15:18, Mike Snitzer wrote:
> 
> >Something must explain the execessive nature of your leak but
> >it isn't a known issue.
> 
> Since I am currently setting up the new machine, all tests were
> performed w/ various live cd images (Fedora Rawhide, Gentoo, ...)
> and I saw the exact same behavior everywhere.
> 
> >Have you tried running with kmemleak enabled?
> 
> I would have to check if that is enabled on the live images but even if
> it is, how would that work? The default interval is 10min. If I fire up
> a dd, the memory is full within two seconds or so... and after that, the
> OOM killer kicks in and all hell breaks loose unfortunately.

You can control when kmemleak scans.  See Documentation/kmemleak.txt

You could manually trigger a scan just after the dd is started.

But I doubt the livecds have kmemleak compiled into their kernels.

> I don't think this is a particular unique issue on my side. You could,
> if I am right, easily try a Fedora Rawhide image and reproduce it there
> yourself. The only unique point here is my RAID10 which is a Intel Rapid
> Storage s/w RAID. I have no clue if this could indeed cause such a "bug"
> and how.

What is your raid10's full stripesize?  Is your dd IO size of 512K
somehow triggering excess R-M-W cycles which is exacerbating the
problem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
