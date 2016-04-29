Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9EAA66B007E
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 14:54:54 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id t184so288355479qkh.3
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 11:54:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a47si8221576qge.3.2016.04.29.11.54.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Apr 2016 11:54:54 -0700 (PDT)
Date: Fri, 29 Apr 2016 14:54:52 -0400
From: Mike Snitzer <snitzer@redhat.com>
Subject: Re: [PATCH 17/20] dm: get rid of superfluous gfp flags
Message-ID: <20160429185451.GA21865@redhat.com>
References: <1461849846-27209-1-git-send-email-mhocko@kernel.org>
 <1461849846-27209-18-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461849846-27209-18-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mikulas Patocka <mpatocka@redhat.com>, Shaohua Li <shli@kernel.org>

On Thu, Apr 28 2016 at  9:24am -0400,
Michal Hocko <mhocko@kernel.org> wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> copy_params seems to be little bit confused about which allocation flags
> to use. It enforces GFP_NOIO even though it uses
> memalloc_noio_{save,restore} which enforces GFP_NOIO at the page
> allocator level automatically (via memalloc_noio_flags). It also
> uses __GFP_REPEAT for the __vmalloc request which doesn't make much
> sense either because vmalloc doesn't rely on costly high order
> allocations. Let's just drop the __GFP_REPEAT and leave the further
> cleanup to later changes.
> 
> Cc: Shaohua Li <shli@kernel.org>
> Cc: Mikulas Patocka <mpatocka@redhat.com>
> Cc: dm-devel@redhat.com
> Signed-off-by: Michal Hocko <mhocko@suse.com>

I've taken this patch for 4.7 but editted the header, see:
https://git.kernel.org/cgit/linux/kernel/git/device-mapper/linux-dm.git/commit/?h=dm-4.7&id=0222c76e96163355620224625c1cd80991086dc7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
