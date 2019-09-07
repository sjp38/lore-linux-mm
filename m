Return-Path: <SRS0=dqyo=XC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E6CBC43140
	for <linux-mm@archiver.kernel.org>; Sat,  7 Sep 2019 19:51:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3A7C20863
	for <linux-mm@archiver.kernel.org>; Sat,  7 Sep 2019 19:51:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="XNDOQKpe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3A7C20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BE026B0005; Sat,  7 Sep 2019 15:51:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36E9A6B0006; Sat,  7 Sep 2019 15:51:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25C5D6B0007; Sat,  7 Sep 2019 15:51:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0057.hostedemail.com [216.40.44.57])
	by kanga.kvack.org (Postfix) with ESMTP id 005576B0005
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 15:51:37 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 99ABF4FF4
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 19:51:37 +0000 (UTC)
X-FDA: 75909169434.29.girls21_8282df8941207
X-HE-Tag: girls21_8282df8941207
X-Filterd-Recvd-Size: 7052
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com [209.85.210.195])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 19:51:36 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id w22so6680783pfi.9
        for <linux-mm@kvack.org>; Sat, 07 Sep 2019 12:51:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=0fvnYJXHftqmLaDN9VxcrA75603ju7GvPjbd/GGKuAo=;
        b=XNDOQKpe4OIdd1eHbyYBtpnClRiEPCmMDuVYOy8+Z7o5lmBY8CVZF/lYp0txyrXWa5
         6aH/AMQ4SsWaZ+CAOqfkEaStl1ML6lff2YJ9oDgVku1Jr0TMgwHmLmtFuf+3TF/MiK+t
         v82mVC4GnzpEf9E8HDDtaxIaUxGxuH9NLEMsZMrLSPe2Pg2cFm4KSTco4XmpjlAp/c3O
         F1JVcF9vQbiTmlscyFApuRCIqyaGcNKniDXw4Hj5K/eNVUUkj316mH8zWXnhWpkD3P6a
         MhVfBcnIn/TDKOrZMEX/O4g13jWqPGG1/VLc3O9T7ly92I7/4l49Dz0fqFQ1u64ZywFN
         5ZpA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:in-reply-to:message-id
         :references:user-agent:mime-version;
        bh=0fvnYJXHftqmLaDN9VxcrA75603ju7GvPjbd/GGKuAo=;
        b=Ceex23LzqdB1MH0ENLsG7zBYK75Tw0JZS5umsUeIXN4LgUFVZpfdG493YA6JIrYCBr
         pWK860WtrFIUcH4mQCxLjHcAp+34HBWbuJK/xEWGADGkUy63AaLR34F31Xlk1fwu7SL/
         cBSiQVzkxuGiDaoCm7TnbMAtVB3hwwP86+oj42LXDuexvWZCCaxCF3BvXS3YLeR96fir
         QhaziJBlybBP28NZy0m2NijyoeMKjCN4/TtiEkKexahwyQNbiVF5Emxf31WpXL/5t54t
         mJoC2w8NE+PBFlFT/HnWfxJSk7yVUyn06kolSJhUfh7z/PTS+8wHIXuLuAU3k0TmZYAt
         gHjA==
X-Gm-Message-State: APjAAAVNtA/iipaQKS3ONOnV8Bu6TQu3qSxttRQRFZ1yMcg7+1V4FQuC
	eHCwfx3ImSzlaFKMuzBMXPLA4w==
X-Google-Smtp-Source: APXvYqykNmt9VWsdDmgl5zJKnzYT1w4jGckkWW0eybfwDmjCJzLY73E3BInbCkb0IOA970kdGHJPpw==
X-Received: by 2002:aa7:8005:: with SMTP id j5mr18484009pfi.50.1567885895101;
        Sat, 07 Sep 2019 12:51:35 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id b24sm10504207pfi.75.2019.09.07.12.51.34
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 07 Sep 2019 12:51:34 -0700 (PDT)
Date: Sat, 7 Sep 2019 12:51:33 -0700 (PDT)
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
In-Reply-To: <alpine.DEB.2.21.1909051345030.217933@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.21.1909071249180.81471@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1909041252230.94813@chino.kir.corp.google.com> <CAHk-=wjmF_MGe5sBDmQB1WGpr+QFWkqboHpL37JYB5WgnG8nMA@mail.gmail.com> <alpine.DEB.2.21.1909051345030.217933@chino.kir.corp.google.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Is there any objection from anybody to applying the first two patches, the 
reverts of the reverts that went into 5.3-rc5, for 5.3 and pursuing 
discussion and development using the last two patches in this series as a 
starting point for a sane allocation policy that just works by default for 
everybody?

Andrea acknowledges the swap storm that he reported would be fixed with 
the last two patches in this series and there has been discussion on how 
they can be extended at the same time that they do not impact allocations 
outside the scope of the discussion here (hugetlb).


On Thu, 5 Sep 2019, David Rientjes wrote:

> On Wed, 4 Sep 2019, Linus Torvalds wrote:
> 
> > > This series reverts those reverts and attempts to propose a more sane
> > > default allocation strategy specifically for hugepages.  Andrea
> > > acknowledges this is likely to fix the swap storms that he originally
> > > reported that resulted in the patches that removed __GFP_THISNODE from
> > > hugepage allocations.
> > 
> > There's no way we can try this for 5.3 even if looks ok. This is
> > "let's try this during the 5.4 merge window" material, and see how it
> > works.
> > 
> > But I'd love affected people to test this all on their loads and post
> > numbers, so that we have actual numbers for this series when we do try
> > to merge it.
> > 
> 
> I'm certainly not proposing the last two patches in the series marked as 
> RFC to be merged.  I'm proposing the first two patches in the series, 
> reverts of the reverts that went into 5.3-rc5, are merged for 5.3 so that 
> we return to the same behavior that we have had for years and semantics 
> that MADV_HUGEPAGE has provided that entire libraries and userspaces have 
> been based on.
> 
> It is very clear that there is a path forward here to address the *bug* 
> that Andrea is reporting: it has become conflated with NUMA allocation 
> policies which is not at all the issue.  Note that if 5.3 is released with 
> these patches that it requires a very specialized usecase to benefit from: 
> workloads that are larger than one socket and *requires* remote memory not 
> being low on memory or fragmented.  If remote memory is as low on memory 
> or fragmented as local memory (like in a datacenter), the reverts that 
> went into 5.3 will double the impact of the very bug being reported 
> because now it's causing swap storms for remote memory as well.  I don't 
> anticipate we'll get numbers for that since it's not a configuration they 
> run in.
> 
> The bug here is reclaim in the page allocator that does not benefit memory 
> compaction because we are failing per-zone watermarks already.  The last 
> two patches in these series avoid that, which is a sane default page 
> allocation policy, and the allow fallback to remote memory only when we 
> can't easily allocate locally.
> 
> We *need* the ability to allocate hugepages locally if compaction can 
> work, anything else kills performance.  5.3-rc7 won't try that, it will 
> simply fallback to remote memory.  We need to try compaction but we do not 
> want to reclaim if failing watermark checks.
> 
> I hope that I'm not being unrealistically optimistic that we can make 
> progress on providing a sane default allocation policy using those last 
> two patches as a starter for 5.4, but I'm strongly suggesting that you 
> take the first two patches to return us to the policy that has existed for 
> years and not allow MADV_HUGEPAGE to be used for immediate remote 
> allocation when local is possible.
> 

