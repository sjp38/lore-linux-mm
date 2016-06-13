Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id A4DDC6B007E
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 10:13:27 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id y193so8714851lfd.1
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 07:13:27 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id v198si15053831wmf.69.2016.06.13.07.13.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 07:13:26 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id r5so15240797wmr.0
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 07:13:26 -0700 (PDT)
Date: Mon, 13 Jun 2016 16:13:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/10 -v4] Handle oom bypass more gracefully
Message-ID: <20160613141324.GK6518@dhcp22.suse.cz>
References: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
 <20160613112348.GC6518@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160613112348.GC6518@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 13-06-16 13:23:48, Michal Hocko wrote:
> On Thu 09-06-16 13:52:07, Michal Hocko wrote:
> > I would like to explore ways how to remove kthreads (use_mm) special
> > case. It shouldn't be that hard, we just have to teach the page fault
> > handler to recognize oom victim mm and enforce EFAULT for kthreads
> > which have borrowed that mm.
> 
> So I was trying to come up with solution for this which would require to
> hook into the pagefault an enforce EFAULT when the mm is being reaped
> by the oom_repaer. Not hard but then I have checked the current users
> and none of them is really needing to read from the userspace (aka
> copy_from_user/get_user). So we actually do not need to do anything
> special.

As pointed out by Tetsuo [1] vhost does realy on copy_from_user. I just
missed that. So scratch this. I will revisit a potential solution for
this but that would be outside of this series scope.

[1] http://lkml.kernel.org/r/201606132252.IAE00593.OJQSFMtVFOLHOF@I-love.SAKURA.ne.jp
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
