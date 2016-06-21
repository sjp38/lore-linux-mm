Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4BD9A6B0253
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 13:46:21 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id na2so20218846lbb.1
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 10:46:21 -0700 (PDT)
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com. [209.85.217.178])
        by mx.google.com with ESMTPS id i6si15105805lfg.192.2016.06.21.10.46.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jun 2016 10:46:20 -0700 (PDT)
Received: by mail-lb0-f178.google.com with SMTP id oe3so15497092lbb.1
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 10:46:19 -0700 (PDT)
Date: Tue, 21 Jun 2016 19:46:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm, oom_reaper: How to handle race with oom_killer_disable() ?
Message-ID: <20160621174617.GA27527@dhcp22.suse.cz>
References: <20160613111943.GB6518@dhcp22.suse.cz>
 <20160621083154.GA30848@dhcp22.suse.cz>
 <201606212003.FFB35429.QtMOJFFFOLSHVO@I-love.SAKURA.ne.jp>
 <20160621114643.GE30848@dhcp22.suse.cz>
 <20160621132736.GF30848@dhcp22.suse.cz>
 <201606220032.EGD09344.VOSQOMFJOLHtFF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606220032.EGD09344.VOSQOMFJOLHtFF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, mgorman@techsingularity.net, hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Wed 22-06-16 00:32:29, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> > Hmm, what about the following instead. It is rather a workaround than a
> > full flaged fix but it seems much more easier and shouldn't introduce
> > new issues.
> 
> Yes, I think that will work. But I think below patch (marking signal_struct
> to ignore TIF_MEMDIE instead of clearing TIF_MEMDIE from task_struct) on top of
> current linux.git will implement no-lockup requirement. No race is possible unlike
> "[PATCH 10/10] mm, oom: hide mm which is shared with kthread or global init".

Not really. Because without the exit_oom_victim from oom_reaper you have
no guarantee that the oom_killer_disable will ever return. I have
mentioned that in the changelog. There is simply no guarantee the oom
victim will ever reach exit_mm->exit_oom_victim.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
