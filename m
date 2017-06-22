Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id E80866B0279
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 06:35:55 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id z48so8244770otz.6
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 03:35:55 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id s58si401218otd.298.2017.06.22.03.35.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Jun 2017 03:35:54 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170602071818.GA29840@dhcp22.suse.cz>
	<201706022013.DCI34351.SHOLFFtJQOMFOV@I-love.SAKURA.ne.jp>
	<CAM_iQpWC9E=hee9xYY7Z4_oAA3wK5VOAve-Q1nMD_1SOXJmiyw@mail.gmail.com>
	<201706041758.DGG86904.SOOVLtMJFOQFFH@I-love.SAKURA.ne.jp>
	<CAM_iQpV61uNwfhK_UKJQQteuzk-6m-2dHTfgFriRWunrN+m=ZQ@mail.gmail.com>
In-Reply-To: <CAM_iQpV61uNwfhK_UKJQQteuzk-6m-2dHTfgFriRWunrN+m=ZQ@mail.gmail.com>
Message-Id: <201706221935.ICC81763.OQFOFLFOJtMHVS@I-love.SAKURA.ne.jp>
Date: Thu, 22 Jun 2017 19:35:40 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xiyou.wangcong@gmail.com
Cc: mhocko@suse.com, akpm@linux-foundation.org, linux-mm@kvack.org, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz

Cong Wang wrote:
> On Sun, Jun 4, 2017 at 1:58 AM, Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
> > You can retry with my kmallocwd patch shown bottom. An example output is
> > at http://I-love.SAKURA.ne.jp/tmp/sample-serial.log .
> >
> > Of course, kmallocwd can gather only basic information. You might need to
> > gather more information by e.g. enabling tracepoints after analyzing basic
> > information.
> 
> Sure, since it is a debugging patch we definitely can try it.
> 
> >
> > Below is kmallocwd patch backpoated for 4.9.30 kernel from
> > http://lkml.kernel.org/r/1495331504-12480-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp .
> > Documentation/malloc-watchdog.txt part is stripped in order to reduce lines.
> 
> Will do. But can't guarantee that we can reproduce it. ;)
> 

Did you get a chance to try reproducing it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
