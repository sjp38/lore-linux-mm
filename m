Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D6CFC10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 23:40:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66165214AE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 23:40:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66165214AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E3B576B0005; Wed, 24 Apr 2019 19:40:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DEA286B0006; Wed, 24 Apr 2019 19:40:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D01896B0007; Wed, 24 Apr 2019 19:40:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8433D6B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 19:40:56 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h10so10721581edn.22
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 16:40:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BlBTLW3u4QV0kYFDgPdZbW95f8FWGq2QONe4yySt1dM=;
        b=KfD6dARgLvembUtbSyW4XwvIHkuPgvvRTxryISkRcxaVij/2Jnubj6DFVHN1uXUhtY
         c/nyytU6jtGmEjEkBUDoKAYgqPxGEgmgxC1RTr5sIpd1ap0D+P311lAXCdunwJ2Qj8vf
         xddZX0yJZTnePRQ933VQgc/jRPg+3IrqBZbTJzq/emqMcrrjGzC0AX51MTYEvMiZLad0
         t5932HGmK9E4OskFtp2BQ8VQ9EGQC4fwCDFbAcsp3wnb8Njd5UMSzcn1pN1m20aipBkX
         ghppU+yxP86zjSnofC7YN5PCKucxNp2P5xk5OGDdebc0eR/ZXlHO+SFaQrIyRTfZyvxp
         ew0g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.192 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAUUyc8M3Ib/3WFvAbzSMjP3nBvHZt2nS38ceisv4DHLuJBj8+b+
	sSKED82WxSquY8P1pJVJjlI9VSrE2fmcerHZlmVo2jPazdkcQhFJdsBbWWjZ75Q9LLAF3Eswyw0
	Rbv3fHxy7iYmCOeIr0+fs08CJD1CMUk3NxL3t9RV4yO7MVOZ5+N4xOX546HlTSCkxTw==
X-Received: by 2002:a17:906:3b47:: with SMTP id h7mr15470756ejf.15.1556149255984;
        Wed, 24 Apr 2019 16:40:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyU7BsZepvVpSINPghsfTwisjuZn/fec+cigMf2ZRg8PJ8TBWJND5ged867TLz9dAezyVrU
X-Received: by 2002:a17:906:3b47:: with SMTP id h7mr15470727ejf.15.1556149254937;
        Wed, 24 Apr 2019 16:40:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556149254; cv=none;
        d=google.com; s=arc-20160816;
        b=pG651EAK1IpAjd9eQURa552JklJQstELzdGszznfNv4sNYXhXN/yOWu4c76bj0dY7n
         vzlr6c1X9165tgkxZSHcec7SF0B6HfJhJ6sSrnTDchULpSycAcCzc5L8vZs44x/VGZQ/
         jvaNF/LhBQUceF9nAnkZ+Q4dlED/ADoOVPXdFSgha5hupM1z13US0BZDuz6VyCuWCnc1
         45f8qDEJN/AOI0LUvXigjNlkSpelM+OqvBTh11K19lZ+367Htt5u5tgdhVLbF0E5G9mF
         XC/13tFjnSJ4LVtx3OgvMIml+czP1wAFRcJ4esSwnwKRD2Ln8R/v3SreJ/z+I0px/zyw
         YFgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=BlBTLW3u4QV0kYFDgPdZbW95f8FWGq2QONe4yySt1dM=;
        b=U9thzPDSRg9CiGO/229pcCjOFL+TrcGR1IyKcz8tYt+v9tCBiKp2U1DWxxwMBY8QQ7
         PYC0dJ0LuM5j2F3EEuZHZS/5g0EwGhXQ1lNXHjnSrCq63BK3DTHVCaAIqgbs2NcU7MKV
         lq4oIFWo55IQAU2M88Xns9G4NRSihq22nHw5BGXBjhPKfNdX5zV3LCZ4quYjQM0VHLnQ
         iZ55oAkWAWf+ltO+BO7pN+LuKFGx3PJjpUqU49z7N4sBkl5YSGusTAI0m3hxlV2ka7P1
         waNnn0tIsonbxBaXlMUg+IpoyGl92mbZ5Qu3hc3mHuPUUhK9fPdmNJ6TK5l0/r+hzHMh
         b6uw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.192 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp24.blacknight.com (outbound-smtp24.blacknight.com. [81.17.249.192])
        by mx.google.com with ESMTPS id j35si2729601ede.214.2019.04.24.16.40.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 16:40:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.192 as permitted sender) client-ip=81.17.249.192;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.192 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp24.blacknight.com (Postfix) with ESMTPS id 6FE80B887C
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 00:40:54 +0100 (IST)
Received: (qmail 21671 invoked from network); 24 Apr 2019 23:40:54 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 24 Apr 2019 23:40:54 -0000
Date: Thu, 25 Apr 2019 00:40:53 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] mm/page_alloc: fix never set ALLOC_NOFRAGMENT flag
Message-ID: <20190424234052.GW18914@techsingularity.net>
References: <20190423120806.3503-1-aryabinin@virtuozzo.com>
 <20190423120806.3503-2-aryabinin@virtuozzo.com>
 <20190423120143.f555f77df02a266ba2a7f1fc@linux-foundation.org>
 <20190424090403.GS18914@techsingularity.net>
 <20190424154624.f1084195c36684453a557718@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190424154624.f1084195c36684453a557718@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 24, 2019 at 03:46:24PM -0700, Andrew Morton wrote:
> On Wed, 24 Apr 2019 10:04:03 +0100 Mel Gorman <mgorman@techsingularity.net> wrote:
> 
> > On Tue, Apr 23, 2019 at 12:01:43PM -0700, Andrew Morton wrote:
> > > On Tue, 23 Apr 2019 15:08:06 +0300 Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> > > 
> > > > Commit 0a79cdad5eb2 ("mm: use alloc_flags to record if kswapd can wake")
> > > > removed setting of the ALLOC_NOFRAGMENT flag. Bring it back.
> > > 
> > > What are the runtime effects of this fix?
> > 
> > The runtime effect is that ALLOC_NOFRAGMENT behaviour is restored so
> > that allocations are spread across local zones to avoid fragmentation
> > due to mixing pageblocks as long as possible.
> 
> OK, thanks.  Is this worth a -stable backport?

Yes, but only for 5.0 obviously and both should be included if that is
the case. I did not push for it initially as problems in this area are
hard for a general user to detect and people have not complained about
5.0's fragmentation handling.

-- 
Mel Gorman
SUSE Labs

