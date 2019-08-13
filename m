Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A25F0C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 23:31:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 633D220644
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 23:31:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="QlqMQuV+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 633D220644
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C43126B000D; Tue, 13 Aug 2019 19:31:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF2F86B000E; Tue, 13 Aug 2019 19:31:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE0F96B0010; Tue, 13 Aug 2019 19:31:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0250.hostedemail.com [216.40.44.250])
	by kanga.kvack.org (Postfix) with ESMTP id 869D86B000D
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 19:31:39 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 24B6152C8
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 23:31:39 +0000 (UTC)
X-FDA: 75819003918.11.walk08_e58bcb591a30
X-HE-Tag: walk08_e58bcb591a30
X-Filterd-Recvd-Size: 5580
Received: from mail-pl1-f193.google.com (mail-pl1-f193.google.com [209.85.214.193])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 23:31:38 +0000 (UTC)
Received: by mail-pl1-f193.google.com with SMTP id bj8so2892462plb.4
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 16:31:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=D76e59tgTT4fezI865GZqOOIIhHiE8Pz1mvIdiTRYog=;
        b=QlqMQuV+hLDHY43nxqRuLY882x3N3q7FhzRdnEtDOkbYGGrf8gIuaIMb9Dy/XVkrSC
         QKfMtfAs3gYKOFmSMG4UESwnRiRKC1D8JpHMPFtxjjx3ke8KjRQnOEWCNs3yAwFUM+gN
         S4OEUPPh1H+2HFvBBiTIctOOU69HwlxYQ2LaE3axijBsYzFAgcufRlU5lYnWzXK/7k8v
         3mDs7onMy+HIZSEGXATbroj9J2Tq3JY4jRKQW+XEsGaZjJ5se4c+81n++TQQaQumrpHT
         qXOQHKEu28o8IpP8J3WuEco5Ba7RZIA31/U7FUzgNubTGu7xmsk3ZJs839mLPOXwxQBx
         6UBg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:in-reply-to:message-id
         :references:user-agent:mime-version;
        bh=D76e59tgTT4fezI865GZqOOIIhHiE8Pz1mvIdiTRYog=;
        b=caJ/gGAsCNTk75/N4+sLv69N5I/7SSlnvERA6Zj6VqAeXIwj7Ah/RHWq17pJ7Hm+YI
         rKulCjZ5pqX2fesAG5gLNir57Qaif8u8ktCQTq3UEOjleTSMG4vVQLGl1NfwlOYcDQUA
         Efq/P+1hLHa1JB7o9SYEoiPYNMXKhnjIxcGan5jDlbEc8s2pawV0bLHEHSlomoSGS4QO
         VPeOATv0q2dSJyUVoXOmpS61NJC6ngTeUw2jtEGJDB+ymXb/LdC1Mr9oyLJdIpcTrxjm
         ns003TZqFQLNW/g8XZrpbgnNRuV088MDcl7AWHe8GZZM8x2SHUxOtouHWvmrxJO5dOeT
         tcvA==
X-Gm-Message-State: APjAAAVi36wp6psFLGqdYUm9xD/fTUo3H3bNiDg1Lf20E8DBkNOasl2X
	wQtFeOYup6z24qF8b0fcm3mWOw==
X-Google-Smtp-Source: APXvYqye3wWNbrVXfL7AlwcDjxnVPIKFZs78APEFo8F+LDE4XyMBjtlCEd17D10uCu0tIqye0ruyMw==
X-Received: by 2002:a17:902:2f43:: with SMTP id s61mr5825768plb.238.1565739096913;
        Tue, 13 Aug 2019 16:31:36 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id u7sm109745096pfm.96.2019.08.13.16.31.35
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 13 Aug 2019 16:31:36 -0700 (PDT)
Date: Tue, 13 Aug 2019 16:31:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Andrew Morton <akpm@linux-foundation.org>
cc: Vlastimil Babka <vbabka@suse.cz>, 
    Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, 
    Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org
Subject: Re: [patch] mm, page_alloc: move_freepages should not examine struct
 page of reserved memory
In-Reply-To: <20190813141630.bd8cee48e6a83ca77eead6ad@linux-foundation.org>
Message-ID: <alpine.DEB.2.21.1908131625310.224017@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1908122036560.10779@chino.kir.corp.google.com> <20190813141630.bd8cee48e6a83ca77eead6ad@linux-foundation.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Aug 2019, Andrew Morton wrote:

> > After commit 907ec5fca3dc ("mm: zero remaining unavailable struct pages"),
> > struct page of reserved memory is zeroed.  This causes page->flags to be 0
> > and fixes issues related to reading /proc/kpageflags, for example, of
> > reserved memory.
> > 
> > The VM_BUG_ON() in move_freepages_block(), however, assumes that
> > page_zone() is meaningful even for reserved memory.  That assumption is no
> > longer true after the aforementioned commit.
> > 
> > There's no reason why move_freepages_block() should be testing the
> > legitimacy of page_zone() for reserved memory; its scope is limited only
> > to pages on the zone's freelist.
> > 
> > Note that pfn_valid() can be true for reserved memory: there is a backing
> > struct page.  The check for page_to_nid(page) is also buggy but reserved
> > memory normally only appears on node 0 so the zeroing doesn't affect this.
> > 
> > Move the debug checks to after verifying PageBuddy is true.  This isolates
> > the scope of the checks to only be for buddy pages which are on the zone's
> > freelist which move_freepages_block() is operating on.  In this case, an
> > incorrect node or zone is a bug worthy of being warned about (and the
> > examination of struct page is acceptable bcause this memory is not
> > reserved).
> 
> I'm thinking Fixes:907ec5fca3dc and Cc:stable?  But 907ec5fca3dc is
> almost a year old, so you were doing something special to trigger this?
> 

We noticed it almost immediately after bringing 907ec5fca3dc in on 
CONFIG_DEBUG_VM builds.  It depends on finding specific free pages in the 
per-zone free area where the math in move_freepages() will bring the start 
or end pfn into reserved memory and wanting to claim that entire pageblock 
as a new migratetype.  So the path will be rare, require CONFIG_DEBUG_VM, 
and require fallback to a different migratetype.

Some struct pages were already zeroed from reserve pages before 
907ec5fca3c so it theoretically could trigger before this commit.  I think 
it's rare enough under a config option that most people don't run that 
others may not have noticed.  I wouldn't argue against a stable tag and 
the backport should be easy enough, but probably wouldn't single out a 
commit that this is fixing.

