Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DEC7DC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 11:33:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5EEC20854
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 11:33:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5EEC20854
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 580358E0004; Thu, 28 Feb 2019 06:33:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 508F18E0001; Thu, 28 Feb 2019 06:33:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F9E98E0004; Thu, 28 Feb 2019 06:33:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id F06198E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 06:33:36 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id k21so5432267eds.19
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 03:33:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=eqr0cxqB3SYpwA9brUYSrp/5/drojrx9Lp3lXJEoFNQ=;
        b=TZjV8hszpTnrHOL3Gz2m1CKaXHoqvZ76wK00BGD+m/m2xdF/tAmOPULl8HCWgNCXDw
         m4+PYlpA4N8jW8xgLaLNJ2cP6ZDT5hrVjwR0PNmL54REFlNpcoT/87IerQ7FgoSrkrlB
         Wkuz4ykguV55iX/Trqx4IEX/Xe5mUcm+l/wZZkWoK2cRDg7iBIjt9S/6WgvYTE0fIGAH
         I6ZNHaTNrkaOVGBH187HnjfOC/QS+9SvYT/nh1qvhKtaIYXQnQma4iSD6yHAo603hUWa
         7ztlQbIzyMhMqH/1p/apbchgvQkw02NUND82eKNC2E1LJ9WSoEwW4ITnIOcH/VJdoSKI
         eCAQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.8 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: AHQUAuYOMqUGe512elHEiPsHdiIwLaJAPL91OQVDZiwqadajsPy3LuPF
	pvkZY4mW6A2ET5tcP/mzfGa2/89ussRtjKgygm9MLGFc87rL1NShqpPL7OIyAqkQkv2wDqATXRj
	q/SaiTT+w8DE6Dpm9e3bsheTswkR+Eda8m1hqMJPyf3v45vfxp+C5XfiWyLv0/oJCmQ==
X-Received: by 2002:a50:9268:: with SMTP id j37mr6450435eda.170.1551353616558;
        Thu, 28 Feb 2019 03:33:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbNC1eutMzfbOTHL0NyVtII81ZXBgSoRvfkZsdGwVttL7kdnTFzx93C0N6lGygSpihFT7JL
X-Received: by 2002:a50:9268:: with SMTP id j37mr6450388eda.170.1551353615838;
        Thu, 28 Feb 2019 03:33:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551353615; cv=none;
        d=google.com; s=arc-20160816;
        b=08E8U5r3jZtLmsUpq+xF/3t96k/RxqacLoI0FZtlbeXlmNcSsA1+NQi6ZKwA0ONKYu
         /OegUvx+2y+fi2Nl067mqczOIeohDSowfYwRNFXs/Aauuk230vPhoaKktCUEy24Jesfp
         SFgDwD8HqRNQeOyfyudf5NCAgfMLcKlcyjDHGPur+3aVbHj1FirvLzkII8UxAMqUQ/wB
         isT3Xt3VKHwke+ND8wBLPUbR4z1x0/ArHZfeHHlejCMNvgOsnjr15W2KT2IiXJ1kX7cn
         JpBi9GdJPuGTfVP1P87gdeZQAwxZZDuCWZkwptZe8AdQus+KbTLljPS4aH6FsteDYpte
         q9XQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=eqr0cxqB3SYpwA9brUYSrp/5/drojrx9Lp3lXJEoFNQ=;
        b=JxrRTminwcj+fZUT82CSf2BhYtaGzrhI4Tg6A4fNqGYA5/nRNwf5w8gpgkNW160Y7W
         a3BzWMqZQt6k4mEfZ5Um524dA3Nuhso7JabGuR/bf8LxkvA7yYsYBJO9WSjKVQOfZT/p
         Cql++GrM3v7fm+xSgL+62WRcALcAGDmcXsvVTUQ5KHJ2VyaZE1bg71CH6Tf1XuM+/BAa
         x2+FkZowe199UeM9gwRaE5JWdn6xv2Uw9XcIxFjUoratzlTJ9bOtjLofX3q9XnIZplFO
         ZG685+4f7pktFCCCVoehmn3kEpebc+mef27UaS1lxWPQGxrdKpfKf6zhy8TsgBhO3W9z
         jcnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.8 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id x17si243197ejc.315.2019.02.28.03.33.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 03:33:35 -0800 (PST)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.8 as permitted sender) client-ip=81.17.249.8;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.8 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 6EDEC988A3
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 11:33:35 +0000 (UTC)
Received: (qmail 27096 invoked from network); 28 Feb 2019 11:33:35 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 28 Feb 2019 11:33:35 -0000
Date: Thu, 28 Feb 2019 11:33:33 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@surriel.com>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 3/4] mm/compaction: pass pgdat to too_many_isolated()
 instead of zone
Message-ID: <20190228113333.GF9565@techsingularity.net>
References: <20190228083329.31892-1-aryabinin@virtuozzo.com>
 <20190228083329.31892-3-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190228083329.31892-3-aryabinin@virtuozzo.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2019 at 11:33:28AM +0300, Andrey Ryabinin wrote:
> too_many_isolated() in mm/compaction.c looks only at node state,
> so it makes more sense to change argument to pgdat instead of zone.
> 
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Rik van Riel <riel@surriel.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

