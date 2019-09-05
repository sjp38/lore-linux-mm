Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CD66C00306
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 20:54:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06CCE206BB
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 20:54:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="GopTnzop"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06CCE206BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 658166B0008; Thu,  5 Sep 2019 16:54:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 632376B000A; Thu,  5 Sep 2019 16:54:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56D4D6B000C; Thu,  5 Sep 2019 16:54:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0195.hostedemail.com [216.40.44.195])
	by kanga.kvack.org (Postfix) with ESMTP id 344476B0008
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 16:54:48 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 979EA181AC9AE
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 20:54:47 +0000 (UTC)
X-FDA: 75902071014.22.board09_811633f04993c
X-HE-Tag: board09_811633f04993c
X-Filterd-Recvd-Size: 6243
Received: from mail-pl1-f194.google.com (mail-pl1-f194.google.com [209.85.214.194])
	by imf26.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 20:54:46 +0000 (UTC)
Received: by mail-pl1-f194.google.com with SMTP id k1so1929443pls.11
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 13:54:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=GXDxXxiCunZuVnnF1WXh8fyTBtwvohzNRCSob8YCkqs=;
        b=GopTnzopJhGc/1E7pEIdNYj2NEOXRitfg7q7knEqeyOrCB56oE1KvBY/akZgWAGqNp
         +CO2TqvOoZRa/Gm04jeqvL+0ls+id2lQ8ynq84VeoITKnEGjdukbHVvrERSVq6Q8youN
         HP/Q1oediJvamd6gH0laUTqRsW+VtIpg0+0J1KHkndTx5FfCjmBursJcsImruJMkxkkD
         t7RT1R8pfb6VuHVvRV+/5VbOm+sU7nqhws7PM2t+VfjZ5Y1wZH23dsAxmvnbxy068ENy
         f9QH9XDheQm3J7k+bVJjSGHWy8yjlW/E6xfPAYO56Gz1vhssx+LJuvkg9CtqyudaBDs4
         7LFw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:in-reply-to:message-id
         :references:user-agent:mime-version;
        bh=GXDxXxiCunZuVnnF1WXh8fyTBtwvohzNRCSob8YCkqs=;
        b=B7OjEwfhARUcUI9lrx3UVMxJEqpAGpjw5T1lcixLrlyYwksAHur7OFkcpz/C802T/A
         nQ9lUz4xLc6MhIk345CoYR6U48H0dXSVB+ADVUM2RFJEwnq/n3gDYrE9NQtP3QTe5l2f
         bND7TQpwYn3xQykJGWyKAL7lXGMuEesWPVPF2dBD0k+Su2Hc3RgTR6SuPauuhJId2vda
         9lAU5rIpZoiqn6BtJGyIEoG57aOrVoWQV+uMw+8+w7TnMsq7g1XCLziiZf5Xmj7T6bnE
         R7Wc/AQH542D1LPELCAlNWz2vY1zJQ+cvHzileBL/L60TASuGZN6L0XY67vHruA2bGOn
         OeoA==
X-Gm-Message-State: APjAAAWaxcqBigSOD2xFPPiAI7FhC7r0OKo9TsuVjXJuUFDoPg5KinlQ
	SSnW5VmE8UL+b5G1OnyF/2Ln1g==
X-Google-Smtp-Source: APXvYqzAYeM22/fyHxCBOrtmbXM7+LXZbeoTfXSzse1HU/s8jOAo6MSqcBcOscaTohoVBfw5DzgyqQ==
X-Received: by 2002:a17:902:9348:: with SMTP id g8mr5794411plp.18.1567716885572;
        Thu, 05 Sep 2019 13:54:45 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id v18sm3394315pfn.24.2019.09.05.13.54.44
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 05 Sep 2019 13:54:44 -0700 (PDT)
Date: Thu, 5 Sep 2019 13:54:44 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Linus Torvalds <torvalds@linux-foundation.org>
cc: Andrew Morton <akpm@linux-foundation.org>, 
    Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, 
    Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, 
    "Kirill A. Shutemov" <kirill@shutemov.name>, 
    Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, 
    Linux-MM <linux-mm@kvack.org>
Subject: Re: [patch for-5.3 0/4] revert immediate fallback to remote
 hugepages
In-Reply-To: <CAHk-=wjmF_MGe5sBDmQB1WGpr+QFWkqboHpL37JYB5WgnG8nMA@mail.gmail.com>
Message-ID: <alpine.DEB.2.21.1909051345030.217933@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1909041252230.94813@chino.kir.corp.google.com> <CAHk-=wjmF_MGe5sBDmQB1WGpr+QFWkqboHpL37JYB5WgnG8nMA@mail.gmail.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 4 Sep 2019, Linus Torvalds wrote:

> > This series reverts those reverts and attempts to propose a more sane
> > default allocation strategy specifically for hugepages.  Andrea
> > acknowledges this is likely to fix the swap storms that he originally
> > reported that resulted in the patches that removed __GFP_THISNODE from
> > hugepage allocations.
> 
> There's no way we can try this for 5.3 even if looks ok. This is
> "let's try this during the 5.4 merge window" material, and see how it
> works.
> 
> But I'd love affected people to test this all on their loads and post
> numbers, so that we have actual numbers for this series when we do try
> to merge it.
> 

I'm certainly not proposing the last two patches in the series marked as 
RFC to be merged.  I'm proposing the first two patches in the series, 
reverts of the reverts that went into 5.3-rc5, are merged for 5.3 so that 
we return to the same behavior that we have had for years and semantics 
that MADV_HUGEPAGE has provided that entire libraries and userspaces have 
been based on.

It is very clear that there is a path forward here to address the *bug* 
that Andrea is reporting: it has become conflated with NUMA allocation 
policies which is not at all the issue.  Note that if 5.3 is released with 
these patches that it requires a very specialized usecase to benefit from: 
workloads that are larger than one socket and *requires* remote memory not 
being low on memory or fragmented.  If remote memory is as low on memory 
or fragmented as local memory (like in a datacenter), the reverts that 
went into 5.3 will double the impact of the very bug being reported 
because now it's causing swap storms for remote memory as well.  I don't 
anticipate we'll get numbers for that since it's not a configuration they 
run in.

The bug here is reclaim in the page allocator that does not benefit memory 
compaction because we are failing per-zone watermarks already.  The last 
two patches in these series avoid that, which is a sane default page 
allocation policy, and the allow fallback to remote memory only when we 
can't easily allocate locally.

We *need* the ability to allocate hugepages locally if compaction can 
work, anything else kills performance.  5.3-rc7 won't try that, it will 
simply fallback to remote memory.  We need to try compaction but we do not 
want to reclaim if failing watermark checks.

I hope that I'm not being unrealistically optimistic that we can make 
progress on providing a sane default allocation policy using those last 
two patches as a starter for 5.4, but I'm strongly suggesting that you 
take the first two patches to return us to the policy that has existed for 
years and not allow MADV_HUGEPAGE to be used for immediate remote 
allocation when local is possible.

