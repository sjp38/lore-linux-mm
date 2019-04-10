Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E002C10F14
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 12:28:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B9702082E
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 12:28:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B9702082E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 675F86B0291; Wed, 10 Apr 2019 08:28:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 623116B0292; Wed, 10 Apr 2019 08:28:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53A886B0293; Wed, 10 Apr 2019 08:28:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 289F46B0291
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 08:28:19 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 18so1846982pgx.11
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 05:28:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=tqhwfCgBlKpPNuy5WsvQDadYlBUphfiVT9ljcpqd7LI=;
        b=QzHYCiU8JSsz94l+pbIpzP5zL8B+nyAznACWKtijKRb9k5d8V3mLH7w/JnXxIfiKwc
         HBmkJnv+ifB7OT7NhoYpD4RlkGfxhRwO9KX46wDHCGAlQPt/yBg7Rf3oL1gcKoPlqYOW
         Tkz3XvoB+xzkN5w4D5++spPBIeK3BOvf4lQ+K+D/UqXYSet6ZDWmMdIaQfgmKR9aWCez
         MR622JtsnEzyf70Zxc3r1X4rgIQrguEoG3zB7v5VPLg9Sf79IX2G5c+Jn6hf9rksRUvh
         S7xSbJ/qSA5Txr5Iddocj3Au6reluyFcoMnvzTNufcibpZn8jAhoL0oBPI3PNiYBUyuc
         U0NA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWyCGaccfsaVuk8NHiDChGWvX5Xucusf9aiWj+aqF8BqNc1rnDm
	NNzxn3N8j7rBrH/QBPkuQucCTUJMMQ/P8XL8/w4z7/uV7y77CuaSpJNqskgklLjXk9t02n5LuVQ
	VEHgEDq7n1rzj9CDws6QP+z6q5xfzL2dYDRh6wWbvz/SSGO40LDv48q7GzhPeWOSdLw==
X-Received: by 2002:a17:902:b60d:: with SMTP id b13mr44050720pls.100.1554899298634;
        Wed, 10 Apr 2019 05:28:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyF9Lfb8lGLxnVL4eGQANjOd0h59UT4XAsxxwTem0lu2dbrbO9RF11u8x7jG6/ocy9T8H20
X-Received: by 2002:a17:902:b60d:: with SMTP id b13mr44050665pls.100.1554899297858;
        Wed, 10 Apr 2019 05:28:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554899297; cv=none;
        d=google.com; s=arc-20160816;
        b=cdA9nnZITbzEADcskHhsn7E32Ulv6/RizZZWzSnG2PsCul4TJPjnhldTtwKtcagM9n
         BxdIgMvKuFX5ZJ2tIk14HJ1gyPkXIlb6Lcto7/f0XUSP8h+KG0I287onNhpgtdas28fv
         vaO81l08t+nYe2gnzNTs4wcogTid/cxR6V8RmLH9D2BzRrPokBI+/b6yK3gC03HOtJJf
         W8TNj/6/cyxVB5yRnN1hQb8YRBr6rA65VhBBGKf8trOZqTWqeOTVjaMU+KrApsi3cR0d
         4N9wTK2Qp/F9MFz9TLEY4E5nizoGF3ctknyi7mn/NO66XiK4t24rvTah7kgisQvsz3EM
         NHuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=tqhwfCgBlKpPNuy5WsvQDadYlBUphfiVT9ljcpqd7LI=;
        b=HQWJ26ueTSL99e14Un2D6y23ILG6SbJV0Aeb7XwV64XpRvDH2qV4UBZNS4X3TBPwep
         BZDSVTD9lBusArOB4LcUJfHagoVHgPFrEIdbZMsIqqQJE+/nt0QlRNRtyoEc77nC5NJB
         g6yWpC2gtv2OLulRkaEcBEa2VY32YqHA7XI0qFQ9GYrCi/DkpQnQpyzEPLbBhwoo+DBK
         ZX6KKLBBHZOUmP7NvvhaZyHQkG3xqKRZLcgu1vDEXUKqmexu99jgVk2Tr5NwR1pGu//e
         CePulYOf1O+dHgACcVPOXPzt/4iFODsGAWStrSpKsNdjstqO0mgVE1UsMKWT0X+mKCvJ
         9gog==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (charybdis-ext.suse.de. [195.135.221.2])
        by mx.google.com with ESMTP id m5si23569388pgc.12.2019.04.10.05.28.17
        for <linux-mm@kvack.org>;
        Wed, 10 Apr 2019 05:28:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id C754A48D1; Wed, 10 Apr 2019 14:28:14 +0200 (CEST)
Date: Wed, 10 Apr 2019 14:28:14 +0200
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Wei Yang <richard.weiyang@gmail.com>, Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: Re: [PATCH] mm/memory_hotplug: Drop memory device reference after
 find_memory_block()
Message-ID: <20190410122811.jqlusigqc2a22647@d104.suse.de>
References: <20190410101455.17338-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190410101455.17338-1-david@redhat.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 10, 2019 at 12:14:55PM +0200, David Hildenbrand wrote:
> While current node handling is probably terribly broken for memory block
> devices that span several nodes (only possible when added during boot,
> and something like that should be blocked completely), properly put the
> device reference we obtained via find_memory_block() to get the nid.

We even have nodes sharing sections, so tricky to "fix".
But I agree that the way memblocks are being handled now sucks big time.

> 
> Fixes: d0dc12e86b31 ("mm/memory_hotplug: optimize memory hotplug")
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Wei Yang <richard.weiyang@gmail.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Arun KS <arunks@codeaurora.org>
> Cc: Mathieu Malaterre <malat@debian.org>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Well spotted David ;-)

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3

