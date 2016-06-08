Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id F23056B0005
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 18:51:22 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 5so33250609ioy.2
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 15:51:22 -0700 (PDT)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id ui10si3722319pac.76.2016.06.08.15.51.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 15:51:22 -0700 (PDT)
Received: by mail-pf0-x22d.google.com with SMTP id t190so6741916pfb.3
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 15:51:22 -0700 (PDT)
Date: Wed, 8 Jun 2016 15:51:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 06/10] mm, oom: kill all tasks sharing the mm
In-Reply-To: <20160608062219.GA22570@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1606081549490.12203@chino.kir.corp.google.com>
References: <1464945404-30157-1-git-send-email-mhocko@kernel.org> <1464945404-30157-7-git-send-email-mhocko@kernel.org> <alpine.DEB.2.10.1606061526440.18843@chino.kir.corp.google.com> <20160606232007.GA624@redhat.com> <alpine.DEB.2.10.1606071514550.18400@chino.kir.corp.google.com>
 <20160608062219.GA22570@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 8 Jun 2016, Michal Hocko wrote:

> > Why is the patch asking users to report oom killing of a process that 
> > raced with setting /proc/pid/oom_score_adj to OOM_SCORE_ADJ_MIN?  What is 
> > possibly actionable about it?
> 
> Well, the primary point is to know whether such races happen in the real
> loads and whether they actually matter. If yes we can harden the locking
> or come up with a less racy solutions.

A thread being set to oom disabled while racing with the oom killer 
obviously isn't a concern: it could very well be set to oom disabled after 
the SIGKILL is sent and before the signal is handled, and that's not even 
fixable without unneeded complexity because we don't know the source of 
the SIGKILL.  Please remove the printk entirely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
