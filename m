Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4C17C00307
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 20:16:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95415207FC
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 20:16:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="OdQ+M7bC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95415207FC
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 042796B0005; Fri,  6 Sep 2019 16:16:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F3C9B6B0006; Fri,  6 Sep 2019 16:16:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4B246B0007; Fri,  6 Sep 2019 16:16:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0028.hostedemail.com [216.40.44.28])
	by kanga.kvack.org (Postfix) with ESMTP id C16E36B0005
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 16:16:52 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 666846120
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 20:16:52 +0000 (UTC)
X-FDA: 75905604264.17.bread84_1bbf4f901f07
X-HE-Tag: bread84_1bbf4f901f07
X-Filterd-Recvd-Size: 5310
Received: from mail-pf1-f194.google.com (mail-pf1-f194.google.com [209.85.210.194])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 20:16:51 +0000 (UTC)
Received: by mail-pf1-f194.google.com with SMTP id y72so5273557pfb.12
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 13:16:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=XpjoT+t3VPIqNty6+N9T0d42yqs+CXC4vRtjt+q0q7o=;
        b=OdQ+M7bCR/Hs87PAgK5bi456+I3hom4IiTzR1sNybd715+6YInSNgJiLw0rRpHZPMi
         CjaBP3CTTZu9FeC5FWYDLiBUENvXKGWPkVYABWUL4nKCD6fZpf4BG+Iex6F9NdjHFQHj
         8+jMcuOvrvlRn4QQ6U0J+daib7Rrvq/aPr2svANxqeK0EG1D144YDT+sCm9505bEfM1e
         8OfKsXCnkc+BGope+zK89PVKVpHCO099vcN+1Yq+/bRfFe9g7aKQhcDXxCAMf1+TJUzN
         3mXVBcCYm0fGT8t1RitjWRrgQqLraI6TnC3ROOVlyJ/bqS6N1CBFd1oftwe9qSTYHNRM
         n7Jg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:in-reply-to:message-id
         :references:user-agent:mime-version;
        bh=XpjoT+t3VPIqNty6+N9T0d42yqs+CXC4vRtjt+q0q7o=;
        b=ESilwcN4+WfSnMT/ZIu89l7VlSove5esQ5UR6IhIUmgtI9TPy3+LeFC/q0Uakb+EHC
         dlWeHF5y8eSmsWbbFRv/TXN1ZNu9DqUV2paU7DN2vD9HPErnVZOB1OX9ocEQh7FKGtku
         Y8affL0jCXk/E2Daj+T8BeZGFOWFeZMX4dB4Z+wS6T6+0v4AFpla6YYG0TgG5ldLJNPO
         CxP+Pp9yFaQJef86uw7yC4GEFr5H69Y3zQGR6g534aOEcGkhcdAZWQwVIZKm7WyPbnWo
         Rtq1BFjLHTUgO5cABYVPhr/krT/lem4s4vsxw/r/DtK+E52Dsy1mhkShesBC9HHsES+d
         nFGg==
X-Gm-Message-State: APjAAAXwjtgRyixkDrR4SqYvHcmk+rTZuduFiMOYTDdQbVr6DqfFl9s9
	GiDheXbOWkzevyIIXn9IVUepAQ==
X-Google-Smtp-Source: APXvYqy6kmrb6Rqhp74ZrCXwb0I57IQq3ixyKOJRHtKUsywDqn/BCFjE6trl3ESF6oEToJYzNCiNjw==
X-Received: by 2002:a63:c006:: with SMTP id h6mr9416225pgg.290.1567801010246;
        Fri, 06 Sep 2019 13:16:50 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id 11sm5406332pgo.43.2019.09.06.13.16.49
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 06 Sep 2019 13:16:49 -0700 (PDT)
Date: Fri, 6 Sep 2019 13:16:48 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Mike Kravetz <mike.kravetz@oracle.com>
cc: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, 
    Linus Torvalds <torvalds@linux-foundation.org>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, 
    "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, 
    linux-mm@kvack.org
Subject: Re: [rfc 3/4] mm, page_alloc: avoid expensive reclaim when compaction
 may not succeed
In-Reply-To: <3468b605-a3a9-6978-9699-57c52a90bd7e@oracle.com>
Message-ID: <alpine.DEB.2.21.1909061314270.150656@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1909041252230.94813@chino.kir.corp.google.com> <alpine.DEB.2.21.1909041253390.94813@chino.kir.corp.google.com> <20190905090009.GF3838@dhcp22.suse.cz> <fab91766-da33-d62f-59fb-c226e4790a91@suse.cz>
 <3468b605-a3a9-6978-9699-57c52a90bd7e@oracle.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 5 Sep 2019, Mike Kravetz wrote:

> I don't have a specific test for this.  It is somewhat common for people
> to want to allocate "as many hugetlb pages as possible".  Therefore, they
> will try to allocate more pages than reasonable for their environment and
> take what they can get.  I 'tested' by simply creating some background
> activity and then seeing how many hugetlb pages could be allocated.  Of
> course, many tries over time in a loop.
> 
> This patch did not cause premature allocation failures in my limited testing.
> The number of pages which could be allocated with and without patch were
> pretty much the same.
> 
> Do note that I tested on top of Andrew's tree which contains this series:
> http://lkml.kernel.org/r/20190806014744.15446-1-mike.kravetz@oracle.com
> Patch 3 in that series causes allocations to fail sooner in the case of
> COMPACT_DEFERRED:
> http://lkml.kernel.org/r/20190806014744.15446-4-mike.kravetz@oracle.com
> 
> hugetlb allocations have the __GFP_RETRY_MAYFAIL flag set.  They are willing
> to retry and wait and callers are aware of this.  Even though my limited
> testing did not show regressions caused by this patch, I would prefer if the
> quick exit did not apply to __GFP_RETRY_MAYFAIL requests.

Good!  I think that is the ideal way of handling it: we can specify the 
preference to actually loop and retry (but still eventually fail) for 
hugetlb allocations specifically for this patch by testing for 
__GFP_RETRY_MAYFAIL.

I can add that to the formal proposal of patches 3 and 4 in this series 
assuming we get 5.3 settled by applying the reverts in patches 1 and 2 so 
that we don't cause various versions of Linux to have different default 
and madvise allocation policies wrt NUMA.

