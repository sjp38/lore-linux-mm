Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 786BD6B0005
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 09:45:01 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id u74so6190446lff.0
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 06:45:01 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id qa9si33481358wjc.112.2016.06.07.06.45.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jun 2016 06:45:00 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id m124so23250266wme.3
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 06:45:00 -0700 (PDT)
Date: Tue, 7 Jun 2016 15:44:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom_reaper: make sure that mmput_async is called
 only when memory was reaped
Message-ID: <20160607134458.GM12305@dhcp22.suse.cz>
References: <1465305264-28715-1-git-send-email-mhocko@kernel.org>
 <201606072018.9DF5k9my%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606072018.9DF5k9my%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 07-06-16 20:30:24, kbuild test robot wrote:
[...]
>    mm/oom_kill.c: In function '__oom_reap_task':
> >> mm/oom_kill.c:490:7: warning: passing argument 1 of 'mmget_not_zero' from incompatible pointer type
>      if (!mmget_not_zero(&mm->mm_users)) {
>           ^

Sigh... My rate of screw ups during rebase for last minute changes is
just too high. Sorry about that!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
