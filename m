Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 09EE26B025F
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 16:36:23 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x28so4189433wma.7
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 13:36:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 195si5351107wmm.151.2017.08.10.13.36.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Aug 2017 13:36:21 -0700 (PDT)
Date: Thu, 10 Aug 2017 22:36:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170810203616.GA17766@dhcp22.suse.cz>
References: <20170810081632.31265-1-mhocko@kernel.org>
 <20170810180554.GT25347@redhat.com>
 <20170810185138.GA8269@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170810185138.GA8269@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Argangeli <andrea@kernel.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 10-08-17 20:51:38, Michal Hocko wrote:
[...]
> OK, let's agree to disagree. As I've said I like when the critical
> section is explicit and we _know_ what it protects. In this case it is
> clear that we have to protect from the page tables tear down and the
> vma destructions. But as I've said I am not going to argue about this
> more. It is more important to finally fix this.

Now that I've reread, it may sound different than I thought. I meant to
say that I will not argue about which solution is better and both
patches are good to go. I will let others to decide but I would be glad
if we go with something finally.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
