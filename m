Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE5C9C32753
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 12:28:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DE4021880
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 12:28:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="hj/Fuo5y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DE4021880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A76F6B0003; Mon, 12 Aug 2019 08:28:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1317D6B0005; Mon, 12 Aug 2019 08:28:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3B316B0006; Mon, 12 Aug 2019 08:28:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0163.hostedemail.com [216.40.44.163])
	by kanga.kvack.org (Postfix) with ESMTP id CCA776B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 08:28:16 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 6CF6A8248AA3
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 12:28:16 +0000 (UTC)
X-FDA: 75813703392.20.gold43_82609b1194505
X-HE-Tag: gold43_82609b1194505
X-Filterd-Recvd-Size: 4512
Received: from mail-qk1-f193.google.com (mail-qk1-f193.google.com [209.85.222.193])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 12:28:15 +0000 (UTC)
Received: by mail-qk1-f193.google.com with SMTP id 201so76669448qkm.9
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 05:28:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=F3NVoBe9n1v2ZfRa55FdnUViyntY9dM8fBRiLu0L+fw=;
        b=hj/Fuo5ytWHe0SJ+13jcDdQMsbU/i1ZIACgIViMzJiw64MJCvg0Xb2wHJG7iO+F4CY
         aU/8Q4e5EoRTDQDpyyngxGAd8VRdCivVvM9K4kJH8VkohD0SyifJp3mGzN0GcVbvBsA6
         4Y51i7Ejn6Y8PGCOwhEemjauQp1RbvuAk+XvQ3vNiR6Z8yE71AQmuSIriJA5+G1/cPmw
         b9Fve7MbxQYSmPLxPc8WFWQFK9ggMft0bP6KTFKqQIAdoHpT+phxWGWiOfnw0VACG5Ib
         rBDe3YqIH8M46+Mj9gTd05nIVBhQ30Y1/5SkXNdMnFNsQXrdNcqB8yDxa3rqTHlr6dLq
         iK8A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=F3NVoBe9n1v2ZfRa55FdnUViyntY9dM8fBRiLu0L+fw=;
        b=nuaIWhYxrJa5NP8aevJjKN7+7IPKFbzVbgQQ71XNelDC7q5P9enAoN9+sjuvjYJXae
         8pbeSToWHn+Cd02VuIPp30WvSkwCCyrUpbCNlk4F2Whccs384ifvtA+ZTDWWCRIRPGxa
         6ED2eONNlCRpGO8vV+7i1JS9yLHk1fX1lUqupCxLIXLW5jYnAW9y13EZE6ahbbFvlNQ/
         kVHb8gauZGpfcv+SSE9Yk/K7CDIzsk3c6lvwfLUR9P4e7nYKSd9BZmhlVe9ONGCQqqPr
         blVlcvSwu1TNnVTQhxFLtQjPJB4tRJB392tZL2QskAmxiewDvMqQ6MyFgH9fWSWoUAMC
         2/dg==
X-Gm-Message-State: APjAAAWciLcXGEgt2zInl/PZq4yjdnZS9A8cOkVGSZfb+643xwNFB4K9
	jy1v40ou2ZtkQY5rHKnoDJV4pA==
X-Google-Smtp-Source: APXvYqwODBrrpXeLg1uZt60+w4xuw/RA5y0XlK9HIDJS76yjPxmVou6ZmWwl4OVp2Tm+2EwyPKY3dw==
X-Received: by 2002:a05:620a:12d2:: with SMTP id e18mr29712440qkl.176.1565612895187;
        Mon, 12 Aug 2019 05:28:15 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id z2sm9588656qtq.7.2019.08.12.05.28.14
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 12 Aug 2019 05:28:14 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hx9Qs-00079D-9F; Mon, 12 Aug 2019 09:28:14 -0300
Date: Mon, 12 Aug 2019 09:28:14 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: ira.weiny@intel.com
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	Theodore Ts'o <tytso@mit.edu>, John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>, Dave Chinner <david@fromorbit.com>,
	linux-xfs@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [RFC PATCH v2 15/19] mm/gup: Introduce vaddr_pin_pages()
Message-ID: <20190812122814.GC24457@ziepe.ca>
References: <20190809225833.6657-1-ira.weiny@intel.com>
 <20190809225833.6657-16-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190809225833.6657-16-ira.weiny@intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2019 at 03:58:29PM -0700, ira.weiny@intel.com wrote:
> From: Ira Weiny <ira.weiny@intel.com>
> 
> The addition of FOLL_LONGTERM has taken on additional meaning for CMA
> pages.
> 
> In addition subsystems such as RDMA require new information to be passed
> to the GUP interface to track file owning information.  As such a simple
> FOLL_LONGTERM flag is no longer sufficient for these users to pin pages.
> 
> Introduce a new GUP like call which takes the newly introduced vaddr_pin
> information.  Failure to pass the vaddr_pin object back to a vaddr_put*
> call will result in a failure if pins were created on files during the
> pin operation.

Is this a 'vaddr' in the traditional sense, ie does it work with
something returned by valloc?

Maybe another name would be better?

I also wish GUP like functions took in a 'void __user *' instead of
the unsigned long to make this clear :\

Jason

