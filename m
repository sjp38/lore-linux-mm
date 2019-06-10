Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96224C4321A
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 21:37:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66ACF2086A
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 21:37:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66ACF2086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE95D6B026B; Mon, 10 Jun 2019 17:37:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D99176B026C; Mon, 10 Jun 2019 17:37:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C61CA6B026D; Mon, 10 Jun 2019 17:37:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8EFA76B026B
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 17:37:03 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d13so17316483edo.5
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 14:37:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=JiXcB4WQLmIJJqLmcgynoRiwGhEmds8s5QxbxY7MpUs=;
        b=immqbqYgcze4ii+RMHo6GgQadd+0SJEiF8OnYPmYmjKbBdQQ5eQ4a05SP7mHdFOjwA
         BHNMk63CSlCO8PWdhKN27lfkuw+J08ffxRw6aLIBGl53GIo8jeVH5Ceb4Szvj7byJiO/
         vrGkcVqOGvueB4FxquYN7DLs9bW1H3Fkjc4cRBsBi+er/G0eTF8mv3ie9G+dbKjgJG4O
         6Z+xdFtEWw3KedI9SNfr/2bqE17ZYUNr0nPNt14LsXNcthd6DNJ/AwwbW6/IBmH3I+U2
         xMHCmxY87VMRucj3TnWrqrAC0400Jpp3TZGA1fVyGqP999YXKr6aHFpKB3dCiYTLRWdv
         13DA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAUTIbQl9ngPeN/acTD9UjvHZYYhY6fvTTQmOBmrcGyqy7tFeFNo
	D7ALXdl6zocISI/jReFcH+Fej4WNtjQcFpH8e0+kasH15EW3TH0saUCvCC5DMb9Fm5/JyJu1RgT
	3bVH9wXE3Rn9cQW2idbMhT1jy9gh/ybeQm/J1HE46QIoCFGQPpeOhx7baw/aKLuToCQ==
X-Received: by 2002:a05:6402:64a:: with SMTP id u10mr35307635edx.35.1560202623098;
        Mon, 10 Jun 2019 14:37:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxu8maRBUAFLr2/wk21wMKquPeIdIl70RT6A62AmFtbPggrtuEcML3KADYgdilZ2NjhrOiu
X-Received: by 2002:a05:6402:64a:: with SMTP id u10mr35307568edx.35.1560202622039;
        Mon, 10 Jun 2019 14:37:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560202622; cv=none;
        d=google.com; s=arc-20160816;
        b=Ea++0OeJlu8XgF2bbbRNJp92JEn0Ez6koOABwoGEao4bnSNUa3pAgLH1ngrAhu7Uu/
         qpsXUX6ejC0iilOZ06ld0k4Jrh5oLD+Rd7J2EdKF4uYb4ExJiYy+8Klvz7COeihFwpUF
         2Q1T6Cyjy72IgvG8EMbbPCkgZuvHRzRv8SuLlLsnZeyO2dHIgMy6gpbs3FaN+KnG2k4O
         eI/Sp5s0DtehcYuvo5pWxzGs5+Tb7npEe001LgIqUZZ9RZTFpS849+fPcU1D3RoBHTZC
         2RvEEe3iZU8DeoTMm6Tbbvyf8ycP3skQTL73fIYyJdEHxvFq8F8cTXfPi+HffTRQCRXu
         J7eQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=JiXcB4WQLmIJJqLmcgynoRiwGhEmds8s5QxbxY7MpUs=;
        b=WfrIgOeWqieXWMOXfH6ND+zqw1Eqi8IR7N/kbQ4p0PUbxBoxQcyrQf5NZpDuRjOScD
         cxCzquDlInyUgIzzW68RaCastcb9LRp+8cc77ieEVUTuwUsNhA/waUQbmBWOsD5DpCBj
         f6Tmls8kBi4ReJl9x8lIVY8abfsiib/f0M0qlK93Mq2sP/ZR7L+MeTYuRkaSsV9Bt+L4
         wpdZQ4zD4UfwPZ3CrEElKjyyj3vsP8naMlWLY3uPFYuJPpLpKh4UBKhqKjErN4uzDPSj
         b2aQ9RaQW9tJx/4Kv/4unz+TCCHWRl16xnFIGJ5B/yYkdNrEhRk6mox/HMOD7O4OJNfs
         yVCA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b57si2285636edd.393.2019.06.10.14.37.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 14:37:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 720E7AAA8;
	Mon, 10 Jun 2019 21:37:00 +0000 (UTC)
Message-ID: <1560202615.3312.6.camel@suse.de>
Subject: Re: [v7 PATCH 1/2] mm: vmscan: remove double slab pressure by
 inc'ing sc->nr_scanned
From: Oscar Salvador <osalvador@suse.de>
To: Yang Shi <yang.shi@linux.alibaba.com>, ying.huang@intel.com, 
	hannes@cmpxchg.org, mhocko@suse.com, mgorman@techsingularity.net, 
	kirill.shutemov@linux.intel.com, josef@toxicpanda.com, hughd@google.com, 
	shakeelb@google.com, hdanton@sina.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Mon, 10 Jun 2019 23:36:55 +0200
In-Reply-To: <1559025859-72759-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1559025859-72759-1-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-05-28 at 14:44 +0800, Yang Shi wrote:
> The commit 9092c71bb724 ("mm: use sc->priority for slab shrink
> targets")
> has broken up the relationship between sc->nr_scanned and slab
> pressure.
> The sc->nr_scanned can't double slab pressure anymore.  So, it sounds
> no
> sense to still keep sc->nr_scanned inc'ed.  Actually, it would
> prevent
> from adding pressure on slab shrink since excessive sc->nr_scanned
> would
> prevent from scan->priority raise.

Hi Yang,

I might be misunderstanding this, but did you mean "prevent from scan-
priority decreasing"?
I guess we are talking about balance_pgdat(), and in case
kswapd_shrink_node() returns true (it means we have scanned more than
we had to reclaim), raise_priority becomes false, and this does not let
sc->priority to be decreased, which has the impact that less pages will
 be reclaimed the next round.

Sorry for bugging here, I just wanted to see if I got this right.


-- 
Oscar Salvador
SUSE L3

