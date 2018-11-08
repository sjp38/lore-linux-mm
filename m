Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7B2E86B05B1
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 04:11:44 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id k14-v6so18405030pls.21
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 01:11:44 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l11-v6si3790816plt.5.2018.11.08.01.11.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 01:11:43 -0800 (PST)
Date: Thu, 8 Nov 2018 10:11:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: stable request: mm, page_alloc: actually ignore mempolicies for
 high priority allocations
Message-ID: <20181108091139.GR27423@dhcp22.suse.cz>
References: <a66fb268-74fe-6f4e-a99f-3257b8a5ac3b@vyatta.att-mail.com>
 <08ae2e51-672a-37de-2aa6-4e49dbc9de02@suse.cz>
 <fa553398-f4bf-3d57-376b-94593fb2c127@vyatta.att-mail.com>
 <20181108090154.GJ2453@dhcp22.suse.cz>
 <4ad07955-05d5-80ea-ebf1-876b0dc6347a@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4ad07955-05d5-80ea-ebf1-876b0dc6347a@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mike Manning <mmanning@vyatta.att-mail.com>, stable@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

On Thu 08-11-18 10:06:35, Vlastimil Babka wrote:
> On 11/8/18 10:01 AM, Michal Hocko wrote:
> > On Thu 08-11-18 08:30:40, Mike Manning wrote:
> > [...]
> >> 1) The original commit was not suitable for backport to 4.14 and should
> >> be reverted.
> > 
> > Yes, the original patch hasn't been marked for the stable tree and as
> > such shouldn't have been backported. Even though it looks simple enough
> > it is not really trivial.
> 
> I think you confused the two patches.
> 
> Original commit 1d26c112959f ("mm, page_alloc: do not break
> __GFP_THISNODE by zonelist reset") was marked for stable, especially
> pre-4.7 where SLAB could be potentially broken.

You are right. My apology!
 
> Commit d6a24df00638 ("mm, page_alloc: actually ignore mempolicies for
> high priority allocations") was not marked stable and is being requested
> in this thread. But I'm reluctant to agree with this without properly
> understanding what went wrong.

Agreed
-- 
Michal Hocko
SUSE Labs
