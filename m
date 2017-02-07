Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 740D56B0069
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 04:54:13 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id h7so24303712wjy.6
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 01:54:13 -0800 (PST)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id n10si4366389wrb.298.2017.02.07.01.54.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 01:54:12 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 0CE13989FC
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 09:54:12 +0000 (UTC)
Date: Tue, 7 Feb 2017 09:54:10 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] vmscan: fix zone balance check in prepare_kswapd_sleep
Message-ID: <20170207095410.6xflcfktwlofbg3f@techsingularity.net>
References: <719282122.1183240.1486298780546.ref@mail.yahoo.com>
 <719282122.1183240.1486298780546@mail.yahoo.com>
 <20170206161715.sfz6lm3vmahlnxx6@techsingularity.net>
 <68644e18-ed8d-0559-4ac2-fb3162f6ba67@yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <68644e18-ed8d-0559-4ac2-fb3162f6ba67@yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shantanu Goel <sgoel01@yahoo.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Feb 06, 2017 at 07:16:46PM -0500, Shantanu Goel wrote:
> > However, note that there is a slight risk that kswapd will sleep for a
> > short interval early due to a very small zone such as ZONE_DMA. If this
> > is a general problem then it'll manifest as less kswapd reclaim and more
> > direct reclaim. If it turns out this is an issue then a revert will not
> > be the right fix. Instead, all the checks for zone_balance will need to
> > account for the only balanced zone being a tiny percentage of memory in
> > the node.
> > 
> 
> I see your point.  Perhaps we can introduce a constraint that
> ensures the balanced zones constitute say 1/4 or 1/2 of
> memory in the classzone?  I believe there used to be such
> a constraint at one time for higher order allocations.
> 

There was but it was fairly complex and I'd rather avoid it if at all
possible and certainly not without data backing it up.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
