Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C595C32753
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 00:00:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E27E02086C
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 00:00:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="WqnDtaZO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E27E02086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E5DD6B0003; Wed, 14 Aug 2019 20:00:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8944E6B0005; Wed, 14 Aug 2019 20:00:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 783DB6B000A; Wed, 14 Aug 2019 20:00:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0119.hostedemail.com [216.40.44.119])
	by kanga.kvack.org (Postfix) with ESMTP id 55D206B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 20:00:32 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 08FE28248AA8
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 00:00:32 +0000 (UTC)
X-FDA: 75822705504.26.toes00_21b5ef334401d
X-HE-Tag: toes00_21b5ef334401d
X-Filterd-Recvd-Size: 4271
Received: from mail-qt1-f193.google.com (mail-qt1-f193.google.com [209.85.160.193])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 00:00:31 +0000 (UTC)
Received: by mail-qt1-f193.google.com with SMTP id e8so619764qtp.7
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 17:00:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=uQcEycbJpYwq03WKUHr1Col8h+hbyHngyQSZBqVtuao=;
        b=WqnDtaZOeGzmOCMQPC4We4PRD3RuiO/IALjyCYVZuuWQ7X8TuNS1arQXC7EG5H/WMM
         QoTLuRO+le+M6rRKQ+g/kpY4oRBlm26psPwlaph+NfO/QHkvqy5y7xLVn5asu5icHcX8
         4+cgO8/3DW0QOxaqqU3N1R3jkqcGn2CA/nu/llYZ7KTrYBM7rhgO5bNv15Mwl/qhHkFr
         xLgkDtM4ecYPJZGJaT+5ygz3Mtzt1oLeN40DNq1h3PCmx2kj0py9uxQtJ3zyBZMMMiMa
         2sMtpruVKWC3ihvALp2SoFVQLWI2B85dMUSqBzp9DgYpURT4u2F3Usbhyj4KoRDhvXLf
         XwZA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=uQcEycbJpYwq03WKUHr1Col8h+hbyHngyQSZBqVtuao=;
        b=uFWbrtuK0IGrBQl+gQCz15BBLe4whZecGNSCPkudYT8jNBqBGXoPbWe14xUa/7e2sj
         5sbxWPUZ/46m5iibdYsBHZ/Ii8pDUEzrcigWFIiLKSMsel3nLEk1USZmy0EMgDXlOVTg
         /J0PQ1YvfICZzhfc09rA8ye4LJl9911l8gUCXyFHiW/SwKm03PKHpFeeXuib/JCevV43
         pYeHa77ajndAeisY7/A8EUY2R+2E+2U9aIop/+e9yq1gIuos5Np8cdXAUAMMvWqR9ew5
         duiAjezVEQ40DB455ottM+qywcPwY40VshjYBZo1tfqC0QPGWp4REukArz7fwUPfx6lv
         I0pQ==
X-Gm-Message-State: APjAAAWNlUa7q59khWpT7rON8FH5YXJj6D7pxe4rKDckQfSjIkSYhq3A
	zylnImhUgS/DgT3p6gF7s4nbGA==
X-Google-Smtp-Source: APXvYqwowo9TRatjr9x+Z0wkhKzzctBv0bQD6WAaHI7YUR2Bla8hl5jGs4NuJx4xbIBRiBZ2H9DzbA==
X-Received: by 2002:ac8:5315:: with SMTP id t21mr1735710qtn.66.1565827231022;
        Wed, 14 Aug 2019 17:00:31 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id u126sm637456qkf.132.2019.08.14.17.00.30
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Aug 2019 17:00:30 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hy3Bt-0003UN-MJ; Wed, 14 Aug 2019 21:00:29 -0300
Date: Wed, 14 Aug 2019 21:00:29 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	David Rientjes <rientjes@google.com>,
	Christian =?utf-8?B?S8O2bmln?= <christian.koenig@amd.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 3/5] mm, notifier: Catch sleeping/blocking for !blockable
Message-ID: <20190815000029.GC11200@ziepe.ca>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
 <20190814202027.18735-4-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190814202027.18735-4-daniel.vetter@ffwll.ch>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 10:20:25PM +0200, Daniel Vetter wrote:
> We need to make sure implementations don't cheat and don't have a
> possible schedule/blocking point deeply burried where review can't
> catch it.
> 
> I'm not sure whether this is the best way to make sure all the
> might_sleep() callsites trigger, and it's a bit ugly in the code flow.
> But it gets the job done.
> 
> Inspired by an i915 patch series which did exactly that, because the
> rules haven't been entirely clear to us.

I thought lockdep already was able to detect:

 spin_lock()
 might_sleep();
 spin_unlock()

Am I mistaken? If yes, couldn't this patch just inject a dummy lockdep
spinlock?

Jason

