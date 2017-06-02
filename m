Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D5EA46B02B4
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 13:00:01 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w79so17730737wme.7
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 10:00:01 -0700 (PDT)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id u22si12778835wrb.323.2017.06.02.10.00.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 10:00:00 -0700 (PDT)
Received: by mail-wm0-x229.google.com with SMTP id d127so31560945wmf.0
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 10:00:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170602071818.GA29840@dhcp22.suse.cz>
References: <1496317427-5640-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170601115936.GA9091@dhcp22.suse.cz> <201706012211.GHI18267.JFOVMSOLFFQHOt@I-love.SAKURA.ne.jp>
 <20170601132808.GD9091@dhcp22.suse.cz> <20170601151022.b17716472adbf0e6d51fb011@linux-foundation.org>
 <20170602071818.GA29840@dhcp22.suse.cz>
From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 2 Jun 2017 09:59:39 -0700
Message-ID: <CAM_iQpUbanE2cDAFjMXkZGFiMo4FVbMZYrCGW3imiK+aB2f0Zg@mail.gmail.com>
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, dave.hansen@intel.com, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, vbabka@suse.cz

On Fri, Jun 2, 2017 at 12:18 AM, Michal Hocko <mhocko@suse.com> wrote:
> The changelog doesn't really explain what is going on and only
> speculates that the excessive warn_alloc is the cause. The kernel is
> 4.9.23.el7.twitter.x86_64 which I suspect contains a lot of stuff on top
> of 4.9. So I would really _like_ to see whether this is reproducible
> with the upstream kernel. Especially when this is a LTP test.

Just FYI: our kernel 4.9.23.el7.twitter.x86_64 is almost same with
the upstream 4.9.23 release, with just _few_ non-mm patches
backported.

We do have test machines to test non-stable kernels but it
is slightly harder to build an upstream kernel on them, I mean
not as convenient as a kernel rpm...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
