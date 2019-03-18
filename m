Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99749C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 07:31:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C6C820854
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 07:31:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C6C820854
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00A296B0007; Mon, 18 Mar 2019 03:31:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFC796B0008; Mon, 18 Mar 2019 03:31:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEB426B000A; Mon, 18 Mar 2019 03:31:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A00546B0007
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 03:31:37 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z98so4309641ede.3
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 00:31:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=38LN7wP8Bj6/md+1JRrZwdm0gCGmQcr4z+R8QnTVIiE=;
        b=Qz93376Qqz6deURSbUw076cWnA6iciPvh2fWdiM8nxv+E6zydacVF6GxfYizVA14EN
         Z6aN0W2tV6HcOw5z2+HGaNMt/VJVoMeIOmBtsEmFZeYKhZ+D4pRFk7BDdrqse4o60cbd
         +/OsK4wtkXMwVmAvnCWf9bs7JVYGXU2TckLHFx89xYhXMU5B6mgugZANP1R8Gvl+TzJp
         28f6T8FrdLqjGHSsw6FBjRkRrl+URo/VaZilov5DNfcT78bf6IvsjduUKc1iE3KIPQiP
         6LVj0SL1MCZvo5hs5gr+1QusSMnfmriL4GYj6otbKkkP6YefxSBfs1OpuMk11a7LjUJU
         UiiQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAW8dheLh+e5Z3rG/XCCgghHzyfMrd59bT2Glk8HvCp4tYctFf2v
	a+QO/yk4BHNa2fM4j5K3g/bFqQdL1HZQa95zJrIuo/TJ4qHCQG+ftBi2OvbmirAEwTYB2qfcUGN
	LX0i7Q4d1iv7wtZXRMyjtjCgrZcbG42McqIDtdyFOXAdHz/varu4vIsXi8tSPRvJt7w==
X-Received: by 2002:aa7:c707:: with SMTP id i7mr12344491edq.260.1552894297214;
        Mon, 18 Mar 2019 00:31:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypIc8vYaoE5mYJXmA6a789HzIk2zxuxW14yT0WGKGITmR1tn5r1L1nAHpiKEt5Oj7q6BMG
X-Received: by 2002:aa7:c707:: with SMTP id i7mr12344436edq.260.1552894296197;
        Mon, 18 Mar 2019 00:31:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552894296; cv=none;
        d=google.com; s=arc-20160816;
        b=Qx+/WZK3vSD2rnnz70k1W/4cuNo0N/nbBu1DLGftu/9hOOIUyrmLhQSOJi3SJG+b1j
         QJJtpKNfrtLPDmnnBngT7BhAmG5hOIzIiWYElngxvEy7DI4fzlVMx0OSTDjhAWlNm7wk
         TYUfjj3XKPEHppYLgsLymcELmQvDz3meMJNpGiDb/2rGISbYGjiRV9lC4L6EsSURp1Rd
         LbQpmQwe7Kb/Q9jhUEZb9JXbVKYks5l8Q4xiGTNqd5DlzpADikYvqqkhMPOTQzt5XaLj
         ZIH/6tjIlN3lFij5WkjufW/9GT4EBzMSZX0v0hFzuH+8/mK7dMnz2VBgT3kNDHwSqWES
         z7UQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=38LN7wP8Bj6/md+1JRrZwdm0gCGmQcr4z+R8QnTVIiE=;
        b=fsKioJvTd9m6yqiXWlzPAIKF+zNrlNWhPiBo6OShnKxb4/J4+fO2EbFUK3Q/svX73e
         9xDvx65/yMPz56NYFlrLNWokx0ReAzArwchWICL4Uk23nJ8SWAOg+OEgGAH9g6eD80Qo
         SDve+KY5GHume5eSRy0wxhvP/EYu6+pp/8iAUQp+nLEUlAizGTC7mYhTSvhxhqvkl0Vd
         d9FzGkLIypsnnNE2pedt8m34efsMGxA5yuiLQ67GMVo+6d5tMKX5CZzDU8gX8JuZgwMD
         BVqtL3Yd2nuOIPPbMYStFiB4p8ZhQlAZk1fAtpdxQc8mixhrTaemgIcGe4X1MttuvoFq
         D8HA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id 93si3851351edk.38.2019.03.18.00.31.36
        for <linux-mm@kvack.org>;
        Mon, 18 Mar 2019 00:31:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id B626C45E0; Mon, 18 Mar 2019 08:31:34 +0100 (CET)
Date: Mon, 18 Mar 2019 08:31:34 +0100
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, david@redhat.com, mike.kravetz@oracle.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 0/2] Unlock 1GB-hugetlb on x86_64
Message-ID: <20190318073130.mgqvtwbxw23hpdok@d104.suse.de>
References: <20190304085147.556-1-osalvador@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190304085147.556-1-osalvador@suse.de>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000112, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 04, 2019 at 09:51:45AM +0100, Oscar Salvador wrote:
> RFC -> V1:
> 	- Split up the patch
> 	- Added Michal's Acked-by
> 
> The RFC version of this patch was discussed here [1], and it did not find any
> objection.
> I decided to split up the former patch because one of the changes enables
> offlining operation for 1GB-hugetlb pages, while the other change is a mere
> cleanup.
> 
> Patch1 contains all the information regarding 1GB-hugetlb pages change.
> 
> [1] https://lore.kernel.org/linux-mm/20190221094212.16906-1-osalvador@suse.de/
> 
> Oscar Salvador (2):
>   mm,memory_hotplug: Unlock 1GB-hugetlb on x86_64
>   mm,memory_hotplug: Drop redundant hugepage_migration_supported check
> 
>  mm/memory_hotplug.c | 7 +------
>  1 file changed, 1 insertion(+), 6 deletions(-)

Andrew, now that the merge window is closed, do you want me to re-base and
re-send this, or will you pick it up as is?

Thanks

-- 
Oscar Salvador
SUSE L3

