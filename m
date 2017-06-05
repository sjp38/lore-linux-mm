Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E46EF6B0292
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 14:25:46 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id w91so10826846wrb.13
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 11:25:46 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id c1si10159052wre.235.2017.06.05.11.25.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 11:25:45 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id x3so3966245wme.0
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 11:25:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201706041758.DGG86904.SOOVLtMJFOQFFH@I-love.SAKURA.ne.jp>
References: <20170601132808.GD9091@dhcp22.suse.cz> <20170601151022.b17716472adbf0e6d51fb011@linux-foundation.org>
 <20170602071818.GA29840@dhcp22.suse.cz> <201706022013.DCI34351.SHOLFFtJQOMFOV@I-love.SAKURA.ne.jp>
 <CAM_iQpWC9E=hee9xYY7Z4_oAA3wK5VOAve-Q1nMD_1SOXJmiyw@mail.gmail.com> <201706041758.DGG86904.SOOVLtMJFOQFFH@I-love.SAKURA.ne.jp>
From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 5 Jun 2017 11:25:24 -0700
Message-ID: <CAM_iQpV61uNwfhK_UKJQQteuzk-6m-2dHTfgFriRWunrN+m=ZQ@mail.gmail.com>
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dave.hansen@intel.com, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, vbabka@suse.cz

On Sun, Jun 4, 2017 at 1:58 AM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> You can retry with my kmallocwd patch shown bottom. An example output is
> at http://I-love.SAKURA.ne.jp/tmp/sample-serial.log .
>
> Of course, kmallocwd can gather only basic information. You might need to
> gather more information by e.g. enabling tracepoints after analyzing basic
> information.

Sure, since it is a debugging patch we definitely can try it.


> Since you said
>
>   The log I sent is partial, but that is already all what we captured,
>   I can't find more in kern.log due to log rotation.
>
> you meant "the log I captured is an incomplete one", don't you?

Right, sorry for my stupid typo.

>
> Below is kmallocwd patch backpoated for 4.9.30 kernel from
> http://lkml.kernel.org/r/1495331504-12480-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp .
> Documentation/malloc-watchdog.txt part is stripped in order to reduce lines.

Will do. But can't guarantee that we can reproduce it. ;)

Thanks a lot!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
