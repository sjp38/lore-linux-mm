Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28C00C76186
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 02:48:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9E1E22BEB
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 02:48:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="JnzxG+M3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9E1E22BEB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 858FB8E0029; Wed, 24 Jul 2019 22:48:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 809F78E001C; Wed, 24 Jul 2019 22:48:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D1A18E0029; Wed, 24 Jul 2019 22:48:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3263E8E001C
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 22:48:38 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id h3so29659696pgc.19
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 19:48:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YCVJwLnHWTMolF6PQnVaDij0CtyOdpIfCsfNKw/ufAw=;
        b=bh2oBUF5/MQs2kjI5+OqexDuMAdZ1KCth2mRuoJu/JbhHSF4SrgFUoBYTg2TZLnqhS
         qFyuHHG9b8P9BJcOLxCGX+YGBTkeQNRBQ7UJInEIQQzjFjQVVDAAUjycrIPX3Br8uEsR
         DxiJACg2t+rW0z7XhiK6GFScBcovoP71O64I0tl4dlW/plOGsFLt9cYTh3lp3gHEMGV8
         Ec3qyPW2zG7zwNeBssp8cc4qHWPSfVkByEq80+hO/getzEfb1e3DAQ+lLx+OSbbsluO2
         0x/SZdLGHSZpGpI/oyZmpxo4ydWO0pDuMUkjHJJsszQyUCpO1LX9tG4nrLpUecoxgPXs
         tuWg==
X-Gm-Message-State: APjAAAUWp27m3EJt9hbuyR3IpZLmPIEhBafVu0uKDLuRItq5fyVmUyEZ
	q6qUefO++XPo727gzdhDrBR5twiJniHNilK5ZV9sScEfECgW55GqzuAW1dc48cyBQM/KFqNCLfn
	0BbmDj2LpVu0oM5gwz9T4SzNkdEfpG8ZctSnazQLQOlUOZXBidXp6WX/on8KDVRNPPw==
X-Received: by 2002:a17:90a:c20e:: with SMTP id e14mr49456904pjt.0.1564022917804;
        Wed, 24 Jul 2019 19:48:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxynqShT/L9mpc39gRxl7gjqr9U9qOdjPRUXhLQnAXy9Dwu6nBkLDdBRm8mqYc09WV3qmu6
X-Received: by 2002:a17:90a:c20e:: with SMTP id e14mr49456863pjt.0.1564022917074;
        Wed, 24 Jul 2019 19:48:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564022917; cv=none;
        d=google.com; s=arc-20160816;
        b=A0AvkpfsFgJhVv6FwZQH2XVp4rk1T6CNIr4Ov+FMp2UrQY/VRGdxWJJAJkTBtzmklc
         ws5D7jqRkT9CkjqYkh8c+inubwgJtkgQTDcPm7ish+oz7Qk7zJgjupNyQdGjT+70vhJf
         aWRCOwZrIobrTfGr33oUbjIchlrb3yxdpEOgkRyE4ux+VLkS+j9GtIMqhHFIWTNrMnAO
         Fv1HW2s9e8SI3VyLhOEudj603DyZHmMWzNCqZF9x7ZqVKAdsi5P1lePnAHOm63n1zneM
         yrmrCx5sEnRxVdtAFGJql0r7n+WfuFp6UFNwqvR1GCOiZQfIBK+L+X1CcG7tCa7Ns/L4
         sjgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=YCVJwLnHWTMolF6PQnVaDij0CtyOdpIfCsfNKw/ufAw=;
        b=ZGJhB7DeQRGA1oJHzSgm7kw9d71WiE0EJlGoDioXGUPWQULZS5jl/+rEOdEyV6QAJu
         Uvc7XXqBTpLQlujuIdkhNxBTfA4t3fx4ChiJ289ZOfcA99BJBecJ9bE1EixjhxL+bmLW
         tEHMZX7XUfLkNNKKGzFI/YQu2NFTtkhA/0jLNC38Up8fel3h65Ey7qM8vHfK/psS6gT7
         t/1j1uCP+SYqrlY0NjiIrR+HI6Na9qdLNua/oqQRsWCAPH6F/sEW5edtUjisxtYzR9XJ
         mIGdfllXPt/UN+FjOsqdahOumlUea/wzaoDnT52GwpQ2Y15fMk62VQ1IuNRTYi20gHuS
         FV0w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=JnzxG+M3;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b21si15301319pjo.49.2019.07.24.19.48.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 19:48:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=JnzxG+M3;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7990F22BE8;
	Thu, 25 Jul 2019 02:48:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564022916;
	bh=YWxaVqhUBxhNakctl9Qk/YX4ee0cDSELqHl7XG/98z0=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=JnzxG+M3g1veiHLMx35BlJ7hi4YjM+QUckJY7zP4n5e9rvPCtvpWqldrs7tU3huZs
	 hZOBCxuM8mEGlJRvz3bg3AO7O+QhhzX0By2Aw3ys0sPHaSLDvv1YFxOVg8B9xrErpp
	 1krPoi09vQ1iDFBWz29WXlNbysr39DZYUzdfWAFo=
Date: Wed, 24 Jul 2019 19:48:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@suse.com, dvyukov@google.com, catalin.marinas@arm.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: page_alloc: document kmemleak's non-blockable
 __GFP_NOFAIL case
Message-Id: <20190724194835.59947a6b4df3c2ae7816470d@linux-foundation.org>
In-Reply-To: <1562964544-59519-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1562964544-59519-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 13 Jul 2019 04:49:04 +0800 Yang Shi <yang.shi@linux.alibaba.com> wrote:

> When running ltp's oom test with kmemleak enabled, the below warning was
> triggerred since kernel detects __GFP_NOFAIL & ~__GFP_DIRECT_RECLAIM is
> passed in:
> 
> ...
>
> The mempool_alloc_slab() clears __GFP_DIRECT_RECLAIM, kmemleak has
> __GFP_NOFAIL set all the time due to commit
> d9570ee3bd1d4f20ce63485f5ef05663866fe6c0 ("kmemleak: allow to coexist
> with fault injection").
> 
> The fault-injection would not try to fail slab or page allocation if
> __GFP_NOFAIL is used and that commit tries to turn off fault injection
> for kmemleak allocation.  Although __GFP_NOFAIL doesn't guarantee no
> failure for all the cases (i.e. non-blockable allocation may fail), it
> still makes sense to the most cases.  Kmemleak is also a debugging tool,
> so it sounds not worth changing the behavior.
> 
> It also meaks sense to keep the warning, so just document the special
> case in the comment.
> 
> ...
>
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4531,8 +4531,14 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>  	 */
>  	if (gfp_mask & __GFP_NOFAIL) {
>  		/*
> -		 * All existing users of the __GFP_NOFAIL are blockable, so warn
> -		 * of any new users that actually require GFP_NOWAIT
> +		 * The users of the __GFP_NOFAIL are expected be blockable,
> +		 * and this is true for the most cases except for kmemleak.
> +		 * The kmemleak pass in __GFP_NOFAIL to skip fault injection,
> +		 * however kmemleak may allocate object at some non-blockable
> +		 * context to trigger this warning.
> +		 *
> +		 * Keep this warning since it is still useful for the most
> +		 * normal cases.
>  		 */

Comment has rather a lot of typos.  I'd normally fix them but I think
I'll duck this patch until the kmemleak situation is addressed, so we
can add a kmemleakless long-term comment, if desired.

