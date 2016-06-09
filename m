Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id F2DA96B007E
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 11:42:00 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id u74so19475540lff.0
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 08:42:00 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id n129si9178734wmn.117.2016.06.09.08.41.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jun 2016 08:41:59 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id m124so11636959wme.3
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 08:41:59 -0700 (PDT)
Date: Thu, 9 Jun 2016 17:41:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 10/10] mm, oom: hide mm which is shared with kthread or
 global init
Message-ID: <20160609154156.GG24777@dhcp22.suse.cz>
References: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
 <1465473137-22531-11-git-send-email-mhocko@kernel.org>
 <201606100015.HBB65678.LSOFFJOFMQHOVt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606100015.HBB65678.LSOFFJOFMQHOVt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Fri 10-06-16 00:15:18, Tetsuo Handa wrote:
[...]
> Nobody will set MMF_OOM_REAPED flag if can_oom_reap == true on
> CONFIG_MMU=n kernel. If a TIF_MEMDIE thread in CONFIG_MMU=n kernel
> is blocked before exit_oom_victim() in exit_mm() from do_exit() is
> called, the system will lock up. This is not handled in the patch
> nor explained in the changelog.

I have made it clear several times that !CONFIG_MMU is not a target
of this patch series nor other OOM changes because I am not convinced
issues which we are trying to solve are real on those platforms. I
am not really sure what you are trying to achieve now with these
!CONFIG_MMU remarks but if you see _real_ regressions for those
configurations please describe them. This generic statements when
CONFIG_MMU implications are put into !CONFIG_MMU context are not really
useful. If there are possible OOM killer deadlocks without this series
then adding these patches shouldn't make them worse.

E.g. this particular patch is basically a noop for !CONFIG_MMU because
use_mm() is MMU specific. It is also highly improbable that a task would
share mm with init...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
