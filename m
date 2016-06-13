Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 084116B025E
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 09:55:05 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c82so29599919wme.2
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 06:55:04 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id m22si11424261wma.83.2016.06.13.06.55.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 06:55:03 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id m124so15071771wme.3
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 06:55:03 -0700 (PDT)
Date: Mon, 13 Jun 2016 15:55:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] mm, thp: remove duplication and fix locking issues
 in swapin
Message-ID: <20160613135502.GI6518@dhcp22.suse.cz>
References: <1464023651-19420-1-git-send-email-ebru.akagunduz@gmail.com>
 <20160523172929.GA4406@debian>
 <20160527131247.GM27686@dhcp22.suse.cz>
 <20160611192106.GA6662@debian>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160611192106.GA6662@debian>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, boaz@plexistor.com

On Sat 11-06-16 22:21:06, Ebru Akagunduz wrote:
> On Fri, May 27, 2016 at 03:12:47PM +0200, Michal Hocko wrote:
[...]
> > IMHO we should drop the current ALLOCSTALL heuristic and replace it with
> > ~__GFP_DIRECT_RECLAIM.
>
> Actually, I don't lean towards to touch do_swap_page giving gfp parameter.
> do_swap_page is also used by do_page_fault, it can cause many side effect
> that I can't see. 

The point of the patch is to keep the current gfp mask from all places
except for the optimistic swapin. This was what my example patch did
AFAIR.
 
> I've just sent a patch series for converting from optimistic to
> conservative and take back allocstall. Maybe that way can be easier to
> be approved and less problemitical.

I will try to have a look but I will be travelling this week so cannot
promise anything.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
