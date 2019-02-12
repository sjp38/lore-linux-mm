Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 074BEC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 14:40:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E296214DA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 14:40:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E296214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F14028E0002; Tue, 12 Feb 2019 09:40:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE9028E0001; Tue, 12 Feb 2019 09:40:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD92D8E0002; Tue, 12 Feb 2019 09:40:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 81D908E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 09:40:28 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id d62so2495710edd.19
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 06:40:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=JlPQSW1hoHuEXEt2upzr7OoYBV+aHyN/lr3kBb+WBy4=;
        b=HZZ0uUs/wmz2t5dDmKHPqV8TLdgLZt7n4g9rcbMywrnUImkjEcLbqYeoF2fVLDHRS7
         5lGcZc23ePZ2HnTLotljMyjZ0iFjlGYF9jXpi/ZBeaA+E5C4HXQLdoQ+7aeDsZWDz9hF
         aYCGekzfpMIfOMYmZIL5Ue35CCCItsLsVU7D/Xg3I7dWcKp9b4xzRRwTyfHiXtTni0sW
         lNR18/WLYvlzv9kBb0PR4OYaN0zukZ+c1kA1XE5mDBnSiZoEfOazV5xIHMgEYGbzyf74
         ICASRvTmGrkat0kxw7IcNzHDsUq/gCPM8+Wenv+HwLbpAmr+1+JkmibAhpwucK1DMPdE
         kzcQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAubfWl2GLWNdwdjmAS6ruY9vtal22YP0H+ofN2T2Li0lpwaFlQzH
	8Sj0j8pavWQDs0neGzX0bM8kWnuphYTQWS4/u8HIS37k7bJ2O884s7wDRNaasSug9T5zeNRzKb6
	9GfWee8WQNUM2J3Bwlm5NqGoOHe9sUd4KtjJkriOCAKVkXMCk8GlBOHGUSF/VJnI=
X-Received: by 2002:a17:906:5285:: with SMTP id c5mr2965076ejm.135.1549982428095;
        Tue, 12 Feb 2019 06:40:28 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZJQdfJzU5p2n8s3XpipsJgvdh3jgqn5UkeyXlKE/79J+0sxCRuDvSgXQGCZ45UvV2vz2OG
X-Received: by 2002:a17:906:5285:: with SMTP id c5mr2965027ejm.135.1549982427209;
        Tue, 12 Feb 2019 06:40:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549982427; cv=none;
        d=google.com; s=arc-20160816;
        b=yO4vCoUYEUZrPLo+qiiTLwUC8jqS1NUbf7r/9WrUZw7SL5L+dUGxPRcnOwExDkTQSu
         342LQ9t26pv0K6+zYFbY81nCQjGfqz+wOaqhVUD95uhYYTyEQiMQfLxD/gY6A5O6aInk
         7hh7f3rQwoNkohGYzWDfFdKrOtNqAtC7T/7aiaxrlreAyjRI1fNcTpUQ9dn6XT/x1WQR
         7s27rHZYQQngfCywzgxoN1inUQtYC48IGjlq5yPwoa9f5stkQqPVVwZe3YgEfKhhyA9F
         wle9ALcWeEpnIjv4J5mzAAHxAYKoceQSQLUSiJZPLRdiQ+mTpQFzjP9zukzoIMpn7SQd
         I6fA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=JlPQSW1hoHuEXEt2upzr7OoYBV+aHyN/lr3kBb+WBy4=;
        b=tMRhnomgmpZ5ZdhJ3Frqve0H/jODblrPRfSvE6wKIaUWIiMZOlFT577tjmj1mW80RY
         iB9/R8y4C/uNwekP7V4j/GPzmYTdw5HmA374DW6cxR6+GhYhvxK0cp3mFxSLSJtEMtLu
         2ag8C3JKGAHlX1Z08+MnOZ23gbVnoJyacZh1EE3a+B+sQFuTWyEyVyBbQLQaNJb+FUip
         aKQfVtOLcWNbcgE7/F/dKKXEqEQBGvul475K1OuOgf++jWaNlxiSYGEZGrulT5LJTCFJ
         +x0ifDi/cO8hPHbRh+VT9eLG5DyDCV37YWaBTQEpWtiqK7OfUzJG0StwjMLEms/dJXGM
         BguQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e14si2715242ejs.209.2019.02.12.06.40.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 06:40:27 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BD1BBAF45;
	Tue, 12 Feb 2019 14:40:26 +0000 (UTC)
Date: Tue, 12 Feb 2019 15:40:26 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, david@redhat.com, anthony.yznaga@oracle.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm,memory_hotplug: Explicitly pass the head to
 isolate_huge_page
Message-ID: <20190212144026.GY15609@dhcp22.suse.cz>
References: <20190208090604.975-1-osalvador@suse.de>
 <20190212083329.GN15609@dhcp22.suse.cz>
 <20190212134546.gubfir6zzwrvmunr@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212134546.gubfir6zzwrvmunr@d104.suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 12-02-19 14:45:49, Oscar Salvador wrote:
> On Tue, Feb 12, 2019 at 09:33:29AM +0100, Michal Hocko wrote:
> > >  
> > >  		if (PageHuge(page)) {
> > >  			struct page *head = compound_head(page);
> > > -			pfn = page_to_pfn(head) + (1<<compound_order(head)) - 1;
> > >  			if (compound_order(head) > PFN_SECTION_SHIFT) {
> > >  				ret = -EBUSY;
> > >  				break;
> > >  			}
> > 
> > Why are we doing this, btw? 
> 
> I assume you are referring to:
> 
> > >                     if (compound_order(head) > PFN_SECTION_SHIFT) {
> > >                             ret = -EBUSY;
> > >                             break;
> > >                     }

yes.

> I thought it was in case we stumble upon a gigantic page, and commit
> (c8721bbbdd36 mm: memory-hotplug: enable memory hotplug to handle hugepage)
> confirms it.
> 
> But I am not really sure if the above condition would still hold on powerpc,
> I wanted to check it but it is a bit more tricky than it is in x86_64 because
> of the different hugetlb sizes.
> Could it be that the above condition is not true, but still the order of that
> hugetlb page goes beyond MAX_ORDER? It is something I have to check.

This check doesn't make much sense in principle. Why should we bail out
based on a section size? We are offlining a pfn range. All that we care
about is whether the hugetlb is migrateable.
-- 
Michal Hocko
SUSE Labs

