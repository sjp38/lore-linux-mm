Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB3CEC76186
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 04:38:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADB5120818
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 04:38:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADB5120818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 489728E0003; Wed, 17 Jul 2019 00:38:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 439CC6B000A; Wed, 17 Jul 2019 00:38:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 301998E0003; Wed, 17 Jul 2019 00:38:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id D77E16B0008
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 00:38:26 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id x2so11504067wru.22
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 21:38:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=7NeqCbr6vMa0lvTgpBXKduJdSQr0P8chsTYZciovDGk=;
        b=K+ERcirY77lkQrNqX64LNfBIMoGUDBhE3OLoj3WPAVjRAN94aD6xxO5JV9BqipcB6C
         0ymaCvum6xyVvsA5Hr1f5dIveyVZ9MSa5Y6H6xPqnrZXqSSsRadtdW+8FyQVmG0tU0/W
         baft2B+jzvTrrM4k6ZRGIny9V24Qp/sK0OpaLsUHVBZTA/okuEuYuy53/5V5URPGjwOO
         DpBvCz1nXf0P2H3NSQbs3aZSJXTGtyppLKM/vnRPLFEwy0Ryt3YuJsAU77vddHkbyyIQ
         7qibvWK6KG4AgBZju4c6tQF1M4VL0Xx8mI8GDUpUDmH/BKeOnbSYQwa8HtBpsvTxEsmJ
         ZsUw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXxZI7BiBw5WyLGxXudSK86fnPtykEgXyL7B+/vemLIIDsc3QH0
	S3UFH0DDlEUQUYh7UXCHz5y7zUSLt72JWAo/ZnK4ApQiZqDlpZ5ggcanlsChDf+PbcYESvbSs5H
	ANBbIgiFLh5W2YwR4XgPlIgyzKdWr0rPg5ssK9o0y1W10+eX/THxqgSScKK4cCtXJdA==
X-Received: by 2002:a05:600c:22ce:: with SMTP id 14mr34436701wmg.27.1563338306405;
        Tue, 16 Jul 2019 21:38:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9CR+N4v46QYwVOcQbKa40StGXHh3y9keugIHolbWND0JS35A47nBB50DvAtfp+RBYdzHV
X-Received: by 2002:a05:600c:22ce:: with SMTP id 14mr34436623wmg.27.1563338305662;
        Tue, 16 Jul 2019 21:38:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563338305; cv=none;
        d=google.com; s=arc-20160816;
        b=gqPOEZXMriJNMyizltVLQi+d+B8nGn8XRVkFI1uzOu1aztCIQBHuTu8wsaHc7UQYEw
         sjHk4NG95w4cpF4bOnDB19jaN1C8yhMNGzXfrcig/MrkQpRP6FwV8Q0Fe3huMgSfxuQW
         27ZWtmu9y5CliWUk/MUOEWhpAnYYdbjm4Qdf9CyW6GVNlVa2ygBlbWcpuI4cVxEYE235
         faTH0kSm2q7MfPlr31pbs2q8edgibXt6dBmmMXf7CU8XvLEi8NGiYJAibVtUT24h3Zw8
         UL81OpaT8Bc6xjQaInM7wTeJUfHi1/RDQGoxs8rg+lYZ6NVp6VUXWZL14hCzBxlHwYaP
         bT0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=7NeqCbr6vMa0lvTgpBXKduJdSQr0P8chsTYZciovDGk=;
        b=oHGYUeaWnMU0IP+GXiTzsoKXqxJgIfpatX/yYnbaNzI6IxpoPiynHt4AQm/0gPdSsX
         /26ZTVWs/mmq0f3ezOzQpvFpEr3hXdSl8mvVK2N/YMagvXTmASkOPHYQURa3B3WLhnJQ
         D5T894jmDOz8UmkwDg+U1N4FYmK2GUQ4CYrS4Uyu8HWUbfOVGWWbmAUuO//CLMA1LIjX
         /vpSzOc/aAfSTNXaBPOZkhg5tZYer7eOLbvGYJuh5oZwsd8xFpLIUky02xBzZYgL5MFZ
         ET+1EV5R9Q/Ga2a/a1pS3gGkLYlrlUwEvLf6osRvALR7BgoODGkvMxZrh8G1ELIpC0p4
         wF4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id l18si14741634wrx.371.2019.07.16.21.38.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 21:38:25 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 416C168B05; Wed, 17 Jul 2019 06:38:24 +0200 (CEST)
Date: Wed, 17 Jul 2019 06:38:24 +0200
From: Christoph Hellwig <hch@lst.de>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Christoph Hellwig <hch@lst.de>, Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	willy@infradead.org, Vlastimil Babka <vbabka@suse.cz>,
	Christoph Lameter <cl@linux.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Lai Jiangshan <jiangshanlai@gmail.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Pekka Enberg <penberg@kernel.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 1/3] mm: document zone device struct page reserved
 fields
Message-ID: <20190717043824.GA4755@lst.de>
References: <20190717001446.12351-1-rcampbell@nvidia.com> <20190717001446.12351-2-rcampbell@nvidia.com> <26a47482-c736-22c4-c21b-eb5f82186363@nvidia.com> <20190717042233.GA4529@lst.de> <ae3936eb-2c08-c4a4-f670-10f25c7e0ed8@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ae3936eb-2c08-c4a4-f670-10f25c7e0ed8@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 16, 2019 at 09:31:33PM -0700, John Hubbard wrote:
> OK, so just delete all the _zd_pad_* fields? Works for me. It's misleading to
> calling something padding, if it's actually unavailable because it's used
> in the other union, so deleting would be even better than commenting.
> 
> In that case, it would still be nice to have this new snippet, right?:

I hope willy can chime in a bit on his thoughts about how the union in
struct page should look like.  The padding at the end of the sub-structs
certainly looks pointless, and other places don't use it either.  But if
we are using the other fields it almost seems to me like we only want to
union the lru field in the first sub-struct instead of overlaying most
of it.

