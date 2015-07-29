Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id DAC5F6B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 08:16:23 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so23539460wib.1
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 05:16:23 -0700 (PDT)
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id gl4si43435565wjb.197.2015.07.29.05.16.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 29 Jul 2015 05:16:22 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id F399F992AF
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 12:16:20 +0000 (UTC)
Date: Wed, 29 Jul 2015 13:16:14 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 0/4] enable migration of driver pages
Message-ID: <20150729121614.GA19352@techsingularity.net>
References: <1436776519-17337-1-git-send-email-gioh.kim@lge.com>
 <20150729104945.GA30872@techsingularity.net>
 <20150729105554.GU16722@phenom.ffwll.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150729105554.GU16722@phenom.ffwll.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>, jlayton@poochiereds.net, bfields@fieldses.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, viro@zeniv.linux.org.uk, mst@redhat.com, koct9i@gmail.com, minchan@kernel.org, aquini@redhat.com, linux-fsdevel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, akpm@linux-foundation.org, Gioh Kim <gurugio@hanmail.net>

On Wed, Jul 29, 2015 at 12:55:54PM +0200, Daniel Vetter wrote:
> On Wed, Jul 29, 2015 at 11:49:45AM +0100, Mel Gorman wrote:
> > On Mon, Jul 13, 2015 at 05:35:15PM +0900, Gioh Kim wrote:
> > > My ARM-based platform occured severe fragmentation problem after long-term
> > > (several days) test. Sometimes even order-3 page allocation failed. It has
> > > memory size 512MB ~ 1024MB. 30% ~ 40% memory is consumed for graphic processing
> > > and 20~30 memory is reserved for zram.
> > > 
> > 
> > The primary motivation of this series is to reduce fragmentation by allowing
> > more kernel pages to be moved. Conceptually that is a worthwhile goal but
> > there should be at least one major in-kernel user and while balloon
> > pages were a good starting point, I think we really need to see what the
> > zram changes look like at the same time.
> 
> I think gpu drivers really would be the perfect candidate for compacting
> kernel page allocations. And this also seems the primary motivation for
> this patch series, so I think that's really what we should use to judge
> these patches.
> 
> Of course then there's the seemingly eternal chicken/egg problem of
> upstream gpu drivers for SoCs :(

I recognised that the driver he had modified was not an in-tree user so
it did not really help the review or the design. I did not think it was
very fair to ask that an in-tree GPU driver be converted when it would not
help the embedded platform of interest. Converting zram is both a useful
illustration of the aops requirements and is expected to be beneficial on
the embedded platform. Now, if a GPU driver author was willing to convert
theirs as an example then that would be useful!

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
