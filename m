Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 50BC76B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:15:05 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r123so14048739wmb.1
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 08:15:05 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 98si6643148wrl.5.2017.07.25.08.15.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Jul 2017 08:15:04 -0700 (PDT)
Date: Tue, 25 Jul 2017 17:15:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170725151500.GL26723@dhcp22.suse.cz>
References: <20170724072332.31903-1-mhocko@kernel.org>
 <20170724140008.sd2n6af6izjyjtda@node.shutemov.name>
 <20170724141526.GM25221@dhcp22.suse.cz>
 <20170724145142.i5xqpie3joyxbnck@node.shutemov.name>
 <20170724161146.GQ25221@dhcp22.suse.cz>
 <20170725141723.ivukwhddk2voyhuc@node.shutemov.name>
 <20170725142617.GI26723@dhcp22.suse.cz>
 <20170725150719.74j7fbfzagrn7olb@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170725150719.74j7fbfzagrn7olb@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 25-07-17 18:07:19, Kirill A. Shutemov wrote:
> On Tue, Jul 25, 2017 at 04:26:17PM +0200, Michal Hocko wrote:
[...]
> > Thanks for retesting Kirill. Are those numbers stable over runs? E.g.
> > the run without the patch has ~3% variance while the one with the patch
> > has it smaller. This sounds suspicious to me. There shouldn't be any
> > lock contention (except for the oom killer) so the lock shouldn't make
> > any difference wrt. variability.
> 
> There's run-to-tun variability. I'll post new numbers for your new test.

That's what I've seen and the variance was quite large. I suspected
shell but if you look at the more dedicated test, the std over avg is
still quite large.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
