Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9F2D06B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 07:16:00 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w143so35181682wmw.3
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 04:16:00 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id w65si26240056wmb.106.2016.04.27.04.15.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 04:15:58 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id r12so11998148wme.0
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 04:15:58 -0700 (PDT)
Date: Wed, 27 Apr 2016 13:15:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: add PF_MEMALLOC_NOFS
Message-ID: <20160427111555.GJ2179@dhcp22.suse.cz>
References: <1461671772-1269-1-git-send-email-mhocko@kernel.org>
 <1461671772-1269-2-git-send-email-mhocko@kernel.org>
 <32e220de-6028-a32c-e6a5-6935b97d277d@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <32e220de-6028-a32c-e6a5-6935b97d277d@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Wed 27-04-16 19:53:21, Tetsuo Handa wrote:
[...]
> > Let's hope that filesystems will drop direct GFP_NOFS (resp. ~__GFP_FS)
> > usage as much and possible and only use a properly documented
> > memalloc_nofs_{save,restore} checkpoints where they are appropriate.
> 
> Is the story simple enough to monotonically replace GFP_NOFS/GFP_NOIO
> with GFP_KERNEL after memalloc_no{fs,io}_{save,restore} are inserted?
> We sometimes delegate some operations to somebody else. Don't we need to
> convey PF_MEMALLOC_NOFS/PF_MEMALLOC_NOIO flags to APIs which interact with
> other threads?

We can add an api to do that if that is really needed.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
