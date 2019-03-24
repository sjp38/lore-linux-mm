Return-Path: <SRS0=4n/l=R3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73F00C43381
	for <linux-mm@archiver.kernel.org>; Sun, 24 Mar 2019 22:19:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 160592133D
	for <linux-mm@archiver.kernel.org>; Sun, 24 Mar 2019 22:19:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 160592133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 750206B0003; Sun, 24 Mar 2019 18:19:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7002A6B0005; Sun, 24 Mar 2019 18:19:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 615CC6B0007; Sun, 24 Mar 2019 18:19:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 293E86B0003
	for <linux-mm@kvack.org>; Sun, 24 Mar 2019 18:19:37 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id v16so7814266pfn.11
        for <linux-mm@kvack.org>; Sun, 24 Mar 2019 15:19:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=L34xO0OcplE0bPQEq3KC+dTFnmpcw8qPT36SK9GAN70=;
        b=RpRUlmZn2QeL37eH6gRcj+byMtlK+oMA6ubWpApGX1/EuV5LDkK6qhDhsypheQ+cev
         LDIThv36B4jlkXWyf82bgUP1Rl1kXCr84Rzw1cY6mihYXaO8eb8nZsdI9YNhSCxhKhA/
         97VaYQsZoAR4iZ1hp/eEYCEKAyl8peHHaWgD9krnprhWEH7TMSm9rzMaAgYnV8aQwjWc
         BdbRTakGSgW21lsr5BUh3Lz3jNZcah1BgVlc+iJVixEpWAkm4J/ZOla8BkIjZOF7WHsa
         Cf32yJiE2+08CdYUGaATz/4v6fkbjpQbs9ez3ONtkIhGDjTZaHPhlIlXq0RDcKE66Haa
         wvUg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 134.134.136.24 as permitted sender) smtp.mailfrom=kbusch@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUndSqhi/TMrTVDb+6OL77tuBbuIpzBkYnHRd1vDtf2ueyrtd6U
	NqRVnlUOkzm3qPlntCu7BFIirg++Z13wi1zPBtQqIWlRYe2UzlYp09tJvTWMWwZ3yiSZe72ekcm
	YtPYtoT4n3sClxmxm/VV00LB6kZoZTob2fhKPTPVElr+WJ7vAx8ObUS9Z4TKuUhQ=
X-Received: by 2002:a63:e310:: with SMTP id f16mr19643104pgh.93.1553465976792;
        Sun, 24 Mar 2019 15:19:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxeoKcaUvTfqzfWuxPeGWo/5YgOyPoTmpDLXQe39v72YUnl7tVaTnoFAWv/ZmLyAFHvBiYf
X-Received: by 2002:a63:e310:: with SMTP id f16mr19643076pgh.93.1553465976028;
        Sun, 24 Mar 2019 15:19:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553465976; cv=none;
        d=google.com; s=arc-20160816;
        b=0v92P3ispbtbFKQKc1zOnW5MN+DU+PzcYY8Epdh2dfGxdS1FqeTgjh4DsdI6GYQSK9
         /HEfvEKHkL85BrO1UefY/bzCqiJXLjos6O6ua876Z+gYk7kiuWSe8WjFoQQS1j18f1xy
         qe8no+2utL8GgWfjrfas+aEF7N+q0LEh2DL/AIPgn1dlIvaixwfdJNBkMWJ7jfg7JT+K
         whSAQb1V29MWnle0a8yOJVsmA2SWDt8Ia9niOtDeRLaDok9iyGVlp2it/LcSBjm/NN0x
         Mg1uLcz8hb/WV6w63AOwsjjqJKqp7x3evvpuJFRVqDlNvmYWBit2tTzBvh/w3uKJLAbu
         l6zQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=L34xO0OcplE0bPQEq3KC+dTFnmpcw8qPT36SK9GAN70=;
        b=CysdKTLf7VqzxMsCmA+phXAyOYb2qLA8B4euXc1u9SCV1AoRKM2YSmMbhw77r3GyOY
         yhvk3fAEgJaNEc716zFNYAr4+sKsBN7Ob3hKToMyMEzOTrzfftz/Swpe29grEH4uE1oI
         XzYGNpTlrO7dhu0KE/PwpbYY5qvSNaKxG+rbJ3z7KW84nv3mU9sFjinyqg9g/6eOPtID
         sof19DyiYF+AGodDrH805Wlda66i+HJHYdv0EIJVep73dTSSkATlQyQcTWMUr4p+dRaw
         k7i1u3jTg5d9trqbDKBe+JlmD1eLHj4agrwKHUOWYKPk9lEb1Z6ueIBmmMMw73vx5pk4
         mI4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 134.134.136.24 as permitted sender) smtp.mailfrom=kbusch@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 66si12862210plc.88.2019.03.24.15.19.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Mar 2019 15:19:36 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 134.134.136.24 as permitted sender) smtp.mailfrom=kbusch@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Mar 2019 15:19:35 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,256,1549958400"; 
   d="scan'208";a="331609997"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by fmsmga005.fm.intel.com with ESMTP; 24 Mar 2019 15:19:34 -0700
Date: Sun, 24 Mar 2019 16:20:41 -0600
From: Keith Busch <kbusch@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@suse.com, mgorman@techsingularity.net, riel@surriel.com,
	hannes@cmpxchg.org, akpm@linux-foundation.org,
	dave.hansen@intel.com, keith.busch@intel.com,
	dan.j.williams@intel.com, fengguang.wu@intel.com, fan.du@intel.com,
	ying.huang@intel.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 06/10] mm: vmscan: demote anon DRAM pages to PMEM node
Message-ID: <20190324222040.GE31194@localhost.localdomain>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <1553316275-21985-7-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1553316275-21985-7-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Mar 23, 2019 at 12:44:31PM +0800, Yang Shi wrote:
>  		/*
> +		 * Demote DRAM pages regardless the mempolicy.
> +		 * Demot anonymous pages only for now and skip MADV_FREE
> +		 * pages.
> +		 */
> +		if (PageAnon(page) && !PageSwapCache(page) &&
> +		    (node_isset(page_to_nid(page), def_alloc_nodemask)) &&
> +		    PageSwapBacked(page)) {
> +
> +			if (has_nonram_online()) {
> +				list_add(&page->lru, &demote_pages);
> +				unlock_page(page);
> +				continue;
> +			}
> +		}
> +
> +		/*
>  		 * Anonymous process memory has backing store?
>  		 * Try to allocate it some swap space here.
>  		 * Lazyfree page could be freed directly
> @@ -1477,6 +1507,25 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page), page);
>  	}
>  
> +	/* Demote pages to PMEM */
> +	if (!list_empty(&demote_pages)) {
> +		int err, target_nid;
> +		nodemask_t used_mask;
> +
> +		nodes_clear(used_mask);
> +		target_nid = find_next_best_node(pgdat->node_id, &used_mask,
> +						 true);
> +
> +		err = migrate_pages(&demote_pages, alloc_new_node_page, NULL,
> +				    target_nid, MIGRATE_ASYNC, MR_DEMOTE);
> +
> +		if (err) {
> +			putback_movable_pages(&demote_pages);
> +
> +			list_splice(&ret_pages, &demote_pages);
> +		}
> +	}
> +
>  	mem_cgroup_uncharge_list(&free_pages);
>  	try_to_unmap_flush();
>  	free_unref_page_list(&free_pages);

How do these pages eventually get to swap when migration fails? Looks
like that's skipped.

And page cache demotion is useful too, we shouldn't consider only
anonymous for this feature.

