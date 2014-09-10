Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 315D96B0036
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 12:58:12 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id p10so8632426pdj.37
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 09:58:11 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id p9si27950485pdr.169.2014.09.10.09.58.10
        for <linux-mm@kvack.org>;
        Wed, 10 Sep 2014 09:58:11 -0700 (PDT)
Message-ID: <54108314.80400@intel.com>
Date: Wed, 10 Sep 2014 09:57:56 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: regression caused by cgroups optimization in 3.17-rc2
References: <54061505.8020500@sr71.net> <5406262F.4050705@intel.com> <54062F32.5070504@sr71.net> <20140904142721.GB14548@dhcp22.suse.cz> <5408CB2E.3080101@sr71.net> <20140905092537.GC26243@dhcp22.suse.cz> <20140910162936.GI25219@dhcp22.suse.cz>
In-Reply-To: <20140910162936.GI25219@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@sr71.net>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, LKML <linux-kernel@vger.kernel.org>

On 09/10/2014 09:29 AM, Michal Hocko wrote:
> I do not have a bigger machine to play with unfortunately. I think the
> patch makes sense on its own. I would really appreciate if you could
> give it a try on your machine with !root memcg case to see how much it
> helped. I would expect similar results to your previous testing without
> the revert and Johannes' patch.

So you want to see before/after this patch:

Subject: [PATCH] mm, memcg: Do not kill release batching in
 free_pages_and_swap_cache

And you want it on top of a kernel with the revert or without?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
