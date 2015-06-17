Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 276546B009A
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 08:11:11 -0400 (EDT)
Received: by wiga1 with SMTP id a1so137450900wig.0
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 05:11:10 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id li12si8712270wic.91.2015.06.17.05.11.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Jun 2015 05:11:09 -0700 (PDT)
Date: Wed, 17 Jun 2015 14:11:04 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC -v2] panic_on_oom_timeout
Message-ID: <20150617121104.GD25056@dhcp22.suse.cz>
References: <20150609170310.GA8990@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150609170310.GA8990@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi,
I was thinking about this and I am more and more convinced that we
shouldn't care about panic_on_oom=2 configuration for now and go with
the simplest solution first. I have revisited my original patch and
replaced delayed work by a timer based on the feedback from Tetsuo.

I think we can rely on timers. A downside would be that we cannot dump
the full OOM report from the IRQ context because we rely on task_lock
which is not IRQ safe. But I do not think we really need it. An OOM
report will be in the log already most of the time and show_mem will
tell us the current memory situation.

What do you think?
---
