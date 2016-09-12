Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7C46A6B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 07:16:26 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l68so3630689wml.3
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 04:16:26 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id hn1si14822892wjb.164.2016.09.12.04.16.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 04:16:25 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id z194so762870wmd.3
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 04:16:25 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/2] do not squash mapping flags and gfp_mask together (was: Re: [PATCH -v2] mm: Don't use radix tree writeback tags for pages in)
Date: Mon, 12 Sep 2016 13:16:06 +0200
Message-Id: <20160912111608.2588-1-mhocko@kernel.org>
In-Reply-To: <20160901091347.GC12147@dhcp22.suse.cz>
References: <20160901091347.GC12147@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, "Huang, Ying" <ying.huang@intel.com>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Wu Fengguang <fengguang.wu@intel.com>

On Thu 01-09-16 11:13:47, Michal Hocko wrote:
> On Wed 31-08-16 14:30:31, Andrew Morton wrote:
> > On Wed, 31 Aug 2016 10:14:59 +0100 Mel Gorman <mgorman@techsingularity.net> wrote:
[...]
> > > I didn't see anything wrong with the patch but it's worth highlighting
> > > that this hunk means we are now out of GFP bits.
> > 
> > Well ugh.  What are we to do about that?
> 
> Can we simply give these AS_ flags their own word in mapping rather than
> squash them together with gfp flags and impose the restriction on the
> number of gfp flags. There was some demand for new gfp flags already and
> mapping flags were in the way.

OK, it seems this got unnoticed. What do you think about the following
two patches? I have only compile tested them and git grep suggests
nobody else should be relying on storing gfp_mask into flags directly.
So either I my grep-foo fools me or this should be safe. The two patches
will come as a reply to this email.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
