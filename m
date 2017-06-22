Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 25F356B0279
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 18:53:41 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id x23so8227200wrb.6
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 15:53:41 -0700 (PDT)
Received: from mail-wr0-x241.google.com (mail-wr0-x241.google.com. [2a00:1450:400c:c0c::241])
        by mx.google.com with ESMTPS id l126si2430216wmd.3.2017.06.22.15.53.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 15:53:39 -0700 (PDT)
Received: by mail-wr0-x241.google.com with SMTP id k67so8151275wrc.1
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 15:53:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201706221935.ICC81763.OQFOFLFOJtMHVS@I-love.SAKURA.ne.jp>
References: <20170602071818.GA29840@dhcp22.suse.cz> <201706022013.DCI34351.SHOLFFtJQOMFOV@I-love.SAKURA.ne.jp>
 <CAM_iQpWC9E=hee9xYY7Z4_oAA3wK5VOAve-Q1nMD_1SOXJmiyw@mail.gmail.com>
 <201706041758.DGG86904.SOOVLtMJFOQFFH@I-love.SAKURA.ne.jp>
 <CAM_iQpV61uNwfhK_UKJQQteuzk-6m-2dHTfgFriRWunrN+m=ZQ@mail.gmail.com> <201706221935.ICC81763.OQFOFLFOJtMHVS@I-love.SAKURA.ne.jp>
From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 22 Jun 2017 15:53:18 -0700
Message-ID: <CAM_iQpW-UHTHErQtoWt0gdYkna3aOFxzfLuudFzP=nvDrpLHZQ@mail.gmail.com>
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dave.hansen@intel.com, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, vbabka@suse.cz

On Thu, Jun 22, 2017 at 3:35 AM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> Cong Wang wrote:
>> On Sun, Jun 4, 2017 at 1:58 AM, Tetsuo Handa
>> <penguin-kernel@i-love.sakura.ne.jp> wrote:
>> > You can retry with my kmallocwd patch shown bottom. An example output is
>> > at http://I-love.SAKURA.ne.jp/tmp/sample-serial.log .
>> >
>> > Of course, kmallocwd can gather only basic information. You might need to
>> > gather more information by e.g. enabling tracepoints after analyzing basic
>> > information.
>>
>> Sure, since it is a debugging patch we definitely can try it.
>>
>> >
>> > Below is kmallocwd patch backpoated for 4.9.30 kernel from
>> > http://lkml.kernel.org/r/1495331504-12480-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp .
>> > Documentation/malloc-watchdog.txt part is stripped in order to reduce lines.
>>
>> Will do. But can't guarantee that we can reproduce it. ;)
>>
>
> Did you get a chance to try reproducing it?

Not yet, I plan to apply your patch to our next kernel release but it
doesn't happen yet. ;) I will let you know if I have any update.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
