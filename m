Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 04BFC6B0007
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 10:05:28 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id t10-v6so11899262wrs.17
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 07:05:27 -0700 (PDT)
Received: from Chamillionaire.breakpoint.cc (Chamillionaire.breakpoint.cc. [2a01:7a0:2:106d:670::1])
        by mx.google.com with ESMTPS id a5-v6si14525466wro.167.2018.07.31.07.05.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 31 Jul 2018 07:05:26 -0700 (PDT)
Date: Tue, 31 Jul 2018 16:05:20 +0200
From: Florian Westphal <fw@strlen.de>
Subject: Re: [Bug 200651] New: cgroups iptables-restor: vmalloc: allocation
 failure
Message-ID: <20180731140520.kpotpihqsmiwhh7l@breakpoint.cc>
References: <ed7090ad-5004-3133-3faf-607d2a9fa90a@suse.cz>
 <d69d7a82-5b70-051f-a517-f602c3ef1fd7@suse.cz>
 <98788618-94dc-5837-d627-8bbfa1ddea57@icdsoft.com>
 <ff19099f-e0f5-d2b2-e124-cc12d2e05dc1@icdsoft.com>
 <20180730135744.GT24267@dhcp22.suse.cz>
 <89ea4f56-6253-4f51-0fb7-33d7d4b60cfa@icdsoft.com>
 <20180730183820.GA24267@dhcp22.suse.cz>
 <56597af4-73c6-b549-c5d5-b3a2e6441b8e@icdsoft.com>
 <6838c342-2d07-3047-e723-2b641bc6bf79@suse.cz>
 <8105b7b3-20d3-5931-9f3c-2858021a4e12@icdsoft.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8105b7b3-20d3-5931-9f3c-2858021a4e12@icdsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Georgi Nikolov <gnikolov@icdsoft.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, netfilter-devel@vger.kernel.org, fw@strlen.de

Georgi Nikolov <gnikolov@icdsoft.com> wrote:
> > No, I think that's rather for the netfilter folks to decide. However, it
> > seems there has been the debate already [1] and it was not found. The
> > conclusion was that __GFP_NORETRY worked fine before, so it should work
> > again after it's added back. But now we know that it doesn't...
> >
> > [1] https://lore.kernel.org/lkml/20180130140104.GE21609@dhcp22.suse.cz/T/#u
> 
> Yes i see. I will add Florian Westphal to CC list. netfilter-devel is
> already in this list so probably have to wait for their opinion.

It hasn't changed, I think having OOM killer zap random processes
just because userspace wants to import large iptables ruleset is not a
good idea.
