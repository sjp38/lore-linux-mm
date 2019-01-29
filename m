Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5060C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 22:53:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BB1D20882
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 22:53:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="v+IFQX2U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BB1D20882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D17D8E0003; Tue, 29 Jan 2019 17:53:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 082068E0001; Tue, 29 Jan 2019 17:53:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EDB438E0003; Tue, 29 Jan 2019 17:53:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id BB2F98E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 17:53:20 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id f10so12237678ywc.21
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 14:53:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=6MYSIu9/mxSgvVDzeyAbkyzekemqllHuVnpF2mA9+JM=;
        b=ABF/gKF9cVAP1jNMUwPZr5mLHemZrOxM47ptr0UUlfvMzc0CTU+NtrbtaWBfv4ycME
         Np5YV+5kZuMev7ANHzRQdMKQziJFCsrnKzP5B94xwxmBMlpuAaCQ2UBUIcgAVHwBsAXi
         kog9ffxz89S7XlF+oHoqq5ahOVyJ0Jm9nuv2yVzXz0MLiEPQLGQm3YbIZVd2bF5L70KJ
         3QDzEQfii83ELbJlmpdWdqszI7Eo2yT1ASUa9jmEnqPP6XA6s77xNGX1gOw5kuIkP7N5
         S+OYWUAZ0kAGPF+nmL/i9TvOVZR8TPVtSYM9fvKQF8iAFFqr+YTnO+Pdzu1+rx/M8YQD
         QkWw==
X-Gm-Message-State: AJcUukecSPYsBDoon/RPfQ5HpbD+kO19E9ZQfSUiYhwc4iW7EPiIOxb8
	eXuxe9l8r0XVAc34GkdZOUMyTFgt3E+4NAGHkG0u8Wd9FnDRLqQuMJhAytYMrhYATZ0leshVniK
	aMBMyZRhyQc+6iiCGxZGhZDWvjX2BmVw6UKuqO/BJAWvcxG1ozsjP5eXBM2ADANhyyRXhfTYmNU
	58qyQnCX0cPmniivy1cjPhj8uCMKvnyuQjN2SqbkaTdDpMz4fTjepiAxLgb7WGXQiA9jShVzJBB
	JZwnOHDA26ysh1ap1vStwLeEDxizFATVKilOqxS4PyIGVFa3gkSaQSIGuDYcsNeG9dtpFqyReXf
	TTnFZdfcYpfMaVL5ZYcJ5oeKDVkTj7DEkDhgqGFwIXLCxW+7+bqolGoalFGcNGC7CIQgGS0gLUX
	o
X-Received: by 2002:a81:ac56:: with SMTP id z22mr27961010ywj.40.1548802400416;
        Tue, 29 Jan 2019 14:53:20 -0800 (PST)
X-Received: by 2002:a81:ac56:: with SMTP id z22mr27960990ywj.40.1548802399873;
        Tue, 29 Jan 2019 14:53:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548802399; cv=none;
        d=google.com; s=arc-20160816;
        b=Mi/uEL96LNma+AMzA5ssEoVby2jbFybqsoTmRtVC9H5NPB3ThSK1GUyZ2E4KakTM/k
         WMx6SrI/n671H4y8osg4tnvl+sCwFvnjnLUWShEgQ+eUIUJUOxrbS9PUyD0QzJSa0U6p
         mKccOGka6j20XrYyvnRsZwN3gwg/3xpr7AnjiKZMLd4erKniAyj8oFXdVaQ4FI2x77Sl
         CQHf2b/Q3jEiiK4mLwEScJFaJih+9USzopPwalWEyAEjS3ful7QvDfK+60DQ4AFOpU4k
         rrmclA2/GiogXadQWj+7dOvs+VMLUQzK89hWZphCKjdq8fS54NfpPCyFHnVAvxCSNK/F
         DRUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=6MYSIu9/mxSgvVDzeyAbkyzekemqllHuVnpF2mA9+JM=;
        b=Z9+kNEB6FH60xWy9PMu63KaT5beynXfy5xA6GZb1T04sjBc0XZTF4X07kJtIbmOsKn
         WSXPu0vqQlMlyfwF05ZeKA0d6ovLkuj7DRfERKyUOxnd1yb04vC0O/GMZtUSO4ztnwEI
         m6lNDDPTzZqHk7B3WLYSWNJ1htm6faMWBVeKEjVlRC5LvqY24MGuGNUKskCDRuYK8bgK
         3nbmqgm95hXSUr52hEvUOvNZm0i6pUI1nPJUMzR1W6tkyT0JWDk4pO0hkvqyP7pprr6I
         CptYDRHx/kww08K257ov4fZil4uvsavLqRHjqbczv90hZGwKDGoBwphc6tl2kgwhcl0g
         7fGg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=v+IFQX2U;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d126sor3411778ybh.195.2019.01.29.14.53.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 14:53:19 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=v+IFQX2U;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=6MYSIu9/mxSgvVDzeyAbkyzekemqllHuVnpF2mA9+JM=;
        b=v+IFQX2U1tBEJewgmJ5IQT8W9FVVwF+gS7oR55ixFbJeRF7KjjVOIbSTaW7vfyuyX+
         zjFJZOO5EVvQvAgZq7GTtAbi0SAPexF0xlpZ6/EkDeSTVwEwCJbwJvuChhXGZyxXx7vF
         0dBbo5wjw63dB2MMh2qwuwVBr0sPkXb7FxDG3gSVDAH7KbVN/bidpdIcXP6Og7YT4RwX
         3Gqzd7Y2Oj67G1PqpHGsGFMkTX+1a39TtEAxbsSC4uXztAb1AfZpEq50Ctpy8pToLNXo
         5KJq3QATze1/eg2Cs5FVThUAYi3WQZTiw96tjPiVav6ClaDAcyEhrbvtPO2Flm0ZWYb5
         54Qw==
X-Google-Smtp-Source: AHgI3IbQOkhPGIi2VDq4AzAvBM7PZMZp6f/mE9dZqw4Ul4vZAEUBaNyh9TTj+V1JCKaR6Z0f3mMHoA==
X-Received: by 2002:a25:db06:: with SMTP id g6mr10082131ybf.498.1548802399444;
        Tue, 29 Jan 2019 14:53:19 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::4:1d25])
        by smtp.gmail.com with ESMTPSA id n16sm18580765ywn.31.2019.01.29.14.53.18
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 14:53:18 -0800 (PST)
Date: Tue, 29 Jan 2019 17:53:17 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@suse.com, akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC v2 PATCH] mm: vmscan: do not iterate all mem cgroups for
 global direct reclaim
Message-ID: <20190129225317.GA15515@cmpxchg.org>
References: <1548799877-10949-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1548799877-10949-1-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 06:11:17AM +0800, Yang Shi wrote:
> In current implementation, both kswapd and direct reclaim has to iterate
> all mem cgroups.  It is not a problem before offline mem cgroups could
> be iterated.  But, currently with iterating offline mem cgroups, it
> could be very time consuming.  In our workloads, we saw over 400K mem
> cgroups accumulated in some cases, only a few hundred are online memcgs.
> Although kswapd could help out to reduce the number of memcgs, direct
> reclaim still get hit with iterating a number of offline memcgs in some
> cases.  We experienced the responsiveness problems due to this
> occassionally.
> 
> A simple test with pref shows it may take around 220ms to iterate 8K memcgs
> in direct reclaim:
>              dd 13873 [011]   578.542919: vmscan:mm_vmscan_direct_reclaim_begin
>              dd 13873 [011]   578.758689: vmscan:mm_vmscan_direct_reclaim_end
> So for 400K, it may take around 11 seconds to iterate all memcgs.
> 
> Here just break the iteration once it reclaims enough pages as what
> memcg direct reclaim does.  This may hurt the fairness among memcgs.  But
> the cached iterator cookie could help to achieve the fairness more or
> less.
> 
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>

Looks sane to me, thanks Yang.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

