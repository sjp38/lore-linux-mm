Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 402BCC04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 14:54:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF9D6206BA
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 14:54:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF9D6206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 75E7D6B0279; Tue, 28 May 2019 10:54:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70F746B027A; Tue, 28 May 2019 10:54:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5FF396B027C; Tue, 28 May 2019 10:54:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2BE776B0279
	for <linux-mm@kvack.org>; Tue, 28 May 2019 10:54:46 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id g11so15898111pfq.7
        for <linux-mm@kvack.org>; Tue, 28 May 2019 07:54:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version:sender
         :precedence:list-id:archived-at:list-archive:list-post
         :content-transfer-encoding;
        bh=7Kj+lJqtsCYo6JwqA7bZB82Qh/jE+Tu1vFi/SfcX0Vw=;
        b=eRn1DKOBNAbOIWTKc6Y3TAeJiwTMoN7bfvoXlRJHFPmNG+jEJh8o6+IDcjpViwjceu
         YTA/LGz7EreXZp7ENA0izVYnPUDmPdQoEAhsyqNErmI7x/L2Qy2a8umG3i+5sb5jykzU
         IozkiUb/Qi5R1QWYe1Q2DOxMQ+kO9RFjmxSoGCqGI+VL5hxAUx1i56Muav0Zi2euwrCa
         udNK7NgoZHmO9bt/TzwYMBkF5NpC5qf+NzGGP19HOwUkuTdo+MyMO8IMxX1sGU5ayURe
         4eUL0HFA4Dc4p7r1N9uZsZdtDVFdLW3udpKb96VZxWtZIzQz07GYXNoR419xKezTiloE
         EV5A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.166 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAVmLsjIBWhbbFJCY8VipdTTB8+GPYIns/kAleT9yy7OIXTDGJKY
	0xqfEsn0c+sTWsFt5JKqN7mSz2NisHS7PS1wMuZ3O2CaJUViOY5XggfW+IvZbuYRWROsdPM91Gt
	7iIHOyA8kwMYs3JRh0OT/QyNlARItWMbChkUhviiTYzEgdqulogPzRlBW8Bn44Dkvcg==
X-Received: by 2002:a63:231d:: with SMTP id j29mr105982546pgj.278.1559055285697;
        Tue, 28 May 2019 07:54:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkL1cVm2l1A6M8HfW8MB5VrTgEafnGTieXye7jjwML1Hjy4L37YbLaSKRk8MkFX/syEEdB
X-Received: by 2002:a63:231d:: with SMTP id j29mr105982505pgj.278.1559055285009;
        Tue, 28 May 2019 07:54:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559055285; cv=none;
        d=google.com; s=arc-20160816;
        b=umLYwtqiH6m/ojT0GqQVV1hfGV8Q6FEvXEWN3/d7JEMMU05X2gAi191BNfZ8W5tQBb
         w5w4KcV0khbpIxlZzMzi0VynA3sRVCgNzbbbZaf7L0cuYkgOUH+RntaQYoSaSaN+L22F
         Onp9uofT9gf6CiS8h3qR3P8L1tWp8GiUBZ2Z2lPVU+35ZCd/P+nxDc2sTZHEoiOiCRyH
         bNq7XYI6TW+P8hNATMJ/3V2Yb1VZUsSuNSZaPMklOmOnBwZQfRp6aK7TXHEpcbNF6QxD
         fHT8pKxwfJ/PWxhMgzpAwn9CU3t6UNnCNFWpipnK+bSXIBDA66kIvJY+VbvCMg53jZ9x
         jd3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:list-post:list-archive:archived-at
         :list-id:precedence:sender:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=7Kj+lJqtsCYo6JwqA7bZB82Qh/jE+Tu1vFi/SfcX0Vw=;
        b=Nffmj44GpvG8upnwQ8oV9yJLu9Z+BpQ2qLA05RmQcSCqVLMVTs1KqbtxBtKZixFVdq
         pP4hZttNGeKyb9wDvnCM1ZOVE7cH+Luc/XmASVR7raS3994EQaxt1kajOUEt1EnwIhES
         8Wf6qqCYPMdR1PwlqLtdiz9CLCiUzXCUcQqB+WltfsFyo79IrpEj+z35JuG4/vFG0mlA
         dEN4wPM1cbinPBAJhzf06f7K7n2KXXUlyO/jZcRHTWeX8ZdWU/BmoLzSfSuw//GqFy6r
         D87G85saWGVaJ5yeXzw3qVwcdyYDTgxdpifXD1jzz4qROSuABghdw1KgL8F3ls0wcGOi
         3kCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.166 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail3-166.sinamail.sina.com.cn (mail3-166.sinamail.sina.com.cn. [202.108.3.166])
        by mx.google.com with SMTP id e67si22555026pgc.11.2019.05.28.07.54.44
        for <linux-mm@kvack.org>;
        Tue, 28 May 2019 07:54:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.3.166 as permitted sender) client-ip=202.108.3.166;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.166 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([123.112.52.157])
	by sina.com with ESMTP
	id 5CED4BB00000730B; Tue, 28 May 2019 22:54:42 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 928312401584
From: Hillf Danton <hdanton@sina.com>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>,
	Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 3/7] mm: introduce MADV_COLD
Date: Tue, 28 May 2019 22:54:32 +0800
Message-Id: <20190520035254.57579-4-minchan@kernel.org>
In-Reply-To: <20190520035254.57579-1-minchan@kernel.org>
References: <20190520035254.57579-1-minchan@kernel.org>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
MIME-Version: 1.0
List-ID: <linux-kernel.vger.kernel.org>
X-Mailing-List: linux-kernel@vger.kernel.org
Archived-At: <https://lore.kernel.org/lkml/20190520035254.57579-4-minchan@kernel.org/>
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190528145432.aTY3UAMkk4fihjUmD4rrpoPkg64ZcTij7eSY3gEI7E8@z>


On Mon, 20 May 2019 12:52:50 +0900 Minchan Kim wrote:
> +unsigned long reclaim_pages(struct list_head *page_list)
> +{
> +	int nid = -1;
> +	unsigned long nr_isolated[2] = {0, };
> +	unsigned long nr_reclaimed = 0;
> +	LIST_HEAD(node_page_list);
> +	struct reclaim_stat dummy_stat;
> +	struct scan_control sc = {
> +		.gfp_mask = GFP_KERNEL,
> +		.priority = DEF_PRIORITY,
> +		.may_writepage = 1,
> +		.may_unmap = 1,
> +		.may_swap = 1,
> +	};
> +
> +	while (!list_empty(page_list)) {
> +		struct page *page;
> +
> +		page = lru_to_page(page_list);
> +		list_del(&page->lru);
> +
> +		if (nid == -1) {
> +			nid = page_to_nid(page);
> +			INIT_LIST_HEAD(&node_page_list);
> +			nr_isolated[0] = nr_isolated[1] = 0;
> +		}
> +
> +		if (nid == page_to_nid(page)) {
> +			list_add(&page->lru, &node_page_list);
> +			nr_isolated[!!page_is_file_cache(page)] +=
> +						hpage_nr_pages(page);
> +			continue;
> +		}
> +
Now, page's node != nid and any page on the node_page_list has
node == nid. 
> +		nid = page_to_nid(page);

After updating nid, we get the node id of the isolated pages lost.

> +
> +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_ANON,
> +					nr_isolated[0]);
> +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_FILE,
> +					nr_isolated[1]);
> +		nr_reclaimed += shrink_page_list(&node_page_list,
> +				NODE_DATA(nid), &sc, TTU_IGNORE_ACCESS,

And nid no longer matches the node of the pages to be shrunk.

> +				&dummy_stat, true);
> +		while (!list_empty(&node_page_list)) {
> +			struct page *page = lru_to_page(page_list);

Non-empty node_page_list will never become empty if pages are deleted
only from the page_list.
> +
> +			list_del(&page->lru);
> +			putback_lru_page(page);
> +		}
> +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_ANON,
> +					-nr_isolated[0]);
> +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_FILE,
> +					-nr_isolated[1]);
> +		nr_isolated[0] = nr_isolated[1] = 0;
> +		INIT_LIST_HEAD(&node_page_list);
> +	}
> +

BR
Hillf

