Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 368B0C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 08:44:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1C882082E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 08:44:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1C882082E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FDEB6B0269; Thu, 11 Apr 2019 04:44:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8ACBB6B026A; Thu, 11 Apr 2019 04:44:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 79DB66B026B; Thu, 11 Apr 2019 04:44:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2BD856B0269
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 04:44:37 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id w3so2730842edt.2
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 01:44:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=nmfoATupWxetV9EcTz/sbn00BkippC4W9DWzyJJNEEE=;
        b=PQgsN30NUBs+L5lZnODixPAPjcOtiPhu50ZdOkAxuSMlDFQ2uSSSqSpgEu+BPzEaZX
         6HYlg/96XVhq+WxamePCpmIQYrmfU2aI7r/qwzEvfhjA7jli6a8HaDYaQMqeWVYVTawo
         v3nQIpnVGnyBM9vUFFyqy5iiBkHw9TW7SUGF72CMVxdbF3p/Z5tlI4Qj3qqn5T/TOtUm
         FUYq1HCrU88IQ8IkkQj4tcx1ZMkNS0EuIM8CguxggMdJWa1FMNGlNX1wehrnjo6WZSKg
         I2pp5K2caPrkuRxWXJSeUOAJ1FPzODxVcci8ncG9oFDsSYy7pzv3DOPwhaGosUKpy0Aj
         19GA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.7 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAWft0w0NE5rQDTQiluk8ampdeoLezPTrtWHiE1mk9QEpdwce36K
	ZqJYh0E+3un47PuVCRos1CyGxY7johg52POalMbMy78LasP2Y9Sj9FAg/5DVSbzGoocycTUJJGu
	NB4RoLO15KY+MBBcBjKgu0ohSvR7KauCs8eO/4zOZDUJF3k2/Mp3bBky5PkISsvBTxg==
X-Received: by 2002:a17:906:184e:: with SMTP id w14mr27214345eje.209.1554972276701;
        Thu, 11 Apr 2019 01:44:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyF/rGacL7dlhKSowwuGvpISmE6WVAPKVygPvhfIpZxRmMnjADZqhugP28JnDKGfCbmXeBi
X-Received: by 2002:a17:906:184e:: with SMTP id w14mr27214315eje.209.1554972275842;
        Thu, 11 Apr 2019 01:44:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554972275; cv=none;
        d=google.com; s=arc-20160816;
        b=XuiElo3zUuI9uoSVycl4UkZvjz0uBTbj0AKAom39cT7khE7Fh39rI2o8A14ENp3MWh
         rV3R3t/pk8Vlyb9GD5pNqweuqtQM0ZQv8RhPZPVqHfxcvfP4A0NiSoTCGTsDEaND/2ZG
         6Z+rgBFOGpeTfutQmaGccMW54N8VDczFshqOdxWlexDQZRMWbjcHf70bgx1nE0/X4SqK
         m8aoOW4dw6BtAxyg5u7tS9LXfjZo3n2eyLvLSA4rHG8Dri32uwAo4QNODfdQLDxz1Wtv
         gMR3lRXy/1g58CZ6BUK9xnxRpB16R7Y4mIwAqFqgQyiFsELU5mCO5orJ5jTKSKoREFCK
         RvCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=nmfoATupWxetV9EcTz/sbn00BkippC4W9DWzyJJNEEE=;
        b=L6HD5PzXsIxPUnjQZkFuOtMGwmCbJauyoztWARhcm+GwDWeDjS27QsaqtoguAL0Zsh
         5ap1MtDkMK/xq9UyH6+x3KzcRAqfEwIhG1F7qG1w9ZHN+TY8mCuAh4reC6T06sj3h4LT
         Ul2X3jZudDXi1nNMTXGIR7IXvTBCVtuM2ZgERQ2FybDavgBziBsj6PbB5VZGjZsoePbB
         tFwT/P7WTn9K1jgzp4ZqHjazaDYn5UMRPJniwclwFJau1t0367C4Cj7I2HW2faW2issz
         ISjyJAggpgse3Y97X9NAtycKGoHOaPM6G2OQN8+GanuIg5CuwJKkpyZFJRBVKcOGgyx2
         2oVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.7 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id q16si1392630edd.40.2019.04.11.01.44.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 01:44:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.7 as permitted sender) client-ip=81.17.249.7;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.7 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id 756C29889D
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 08:44:35 +0000 (UTC)
Received: (qmail 29726 invoked from network); 11 Apr 2019 08:44:35 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 11 Apr 2019 08:44:35 -0000
Date: Thu, 11 Apr 2019 09:44:33 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Tobin C. Harding" <me@tobin.cc>, Vlastimil Babka <vbabka@suse.cz>,
	"Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>,
	Qian Cai <cai@lca.pw>,
	Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 0/1] mm: Remove the SLAB allocator
Message-ID: <20190411084433.GC18914@techsingularity.net>
References: <20190410024714.26607-1-tobin@kernel.org>
 <f06aaeae-28c0-9ea4-d795-418ec3362d17@suse.cz>
 <20190410081618.GA25494@eros.localdomain>
 <20190411075556.GO10383@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190411075556.GO10383@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 09:55:56AM +0200, Michal Hocko wrote:
> > > FWIW, our enterprise kernel use it (latest is 4.12 based), and openSUSE
> > > kernels as well (with openSUSE Tumbleweed that includes latest
> > > kernel.org stables). AFAIK we don't enable SLAB_DEBUG even in general
> > > debug kernel flavours as it's just too slow.
> > 
> > Ok, so that probably already kills this.  Thanks for the response.  No
> > flaming, no swearing, man! and they said LKML was a harsh environment ...
> > 
> > > IIRC last time Mel evaluated switching to SLUB, it wasn't a clear
> > > winner, but I'll just CC him for details :)
> > 
> > Probably don't need to take up too much of Mel's time, if we have one
> > user in production we have to keep it, right.
> 
> Well, I wouldn't be opposed to dropping SLAB. Especially when this is
> not a longterm stable kmalloc implementation anymore. It turned out that
> people want to push features from SLUB back to SLAB and then we are just
> having two featurefull allocators and double the maintenance cost.
> 

Indeed.

> So as long as the performance gap is no longer there and the last data
> from Mel (I am sorry but I cannot find a link handy) suggests that there
> is no overall winner in benchmarks then why to keep them both?
> 

The link isn't public. It was based on kernel 5.0 but I still haven't
gotten around to doing a proper writeup. The very short summary is that
with the defaults, SLUB is either performance-neutral or a win versus slab
which is a big improvement over a few years ago. It's worth noting that
there still is a partial relianace on it using high-order pages to get
that performance. If the max order is 0 then there are cases when SLUB
is a loss *but* even that is not universal.  hackbench using processes
and sockets to communicate seems to be the hardest hit when SLUB is not
using high-order pages. This still allows the possibility that SLUB can
degrade over time if the system gets badly enough fragmented and there
are cases where kcompactd and fragmentation avoidance will be more active
than it was relative to SLAB. Again, this is much better than it was a
few years ago and I'm not aware of bug reports that point to compaction
overhead due to SLUB.

> That being said, if somebody is willing to go and benchmark both
> allocators to confirm Mel's observations and current users of SLAB
> can confirm their workloads do not regress either then let's just drop
> it.
> 

Independent verification would be nice. Of particular interest would be
a real set of networking tests on a high-speed network. The hardware in
the test grid I use doesn't have a fast enough network for me to draw a
reliable conclusion.

-- 
Mel Gorman
SUSE Labs

