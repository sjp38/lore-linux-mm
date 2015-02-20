Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 981FF6B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 06:22:52 -0500 (EST)
Received: by pdjy10 with SMTP id y10so6923061pdj.13
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 03:22:52 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id pr2si28843612pdb.188.2015.02.20.03.22.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 20 Feb 2015 03:22:51 -0800 (PST)
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
	<20150217125315.GA14287@phnom.home.cmpxchg.org>
	<20150217225430.GJ4251@dastard>
	<20150219102431.GA15569@phnom.home.cmpxchg.org>
	<20150219225217.GY12722@dastard>
In-Reply-To: <20150219225217.GY12722@dastard>
Message-Id: <201502201936.HBH34799.SOLFFFQtHOMOJV@I-love.SAKURA.ne.jp>
Date: Fri, 20 Feb 2015 19:36:33 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, hannes@cmpxchg.org
Cc: mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

Dave Chinner wrote:
> I really don't care about the OOM Killer corner cases - it's
> completely the wrong way line of development to be spending time on
> and you aren't going to convince me otherwise. The OOM killer a
> crutch used to justify having a memory allocation subsystem that
> can't provide forward progress guarantee mechanisms to callers that
> need it.

I really care about the OOM Killer corner cases, for I'm

  (1) seeing trouble cases which occurred in enterprise systems
      under OOM conditions

  (2) trying to downgrade OOM "Deadlock or Genocide" attacks (which
      an unprivileged user with a login shell can trivially trigger
      since Linux 2.0) to OOM "Genocide" attacks in order to allow
      OOM-unkillable daemons to restart OOM-killed processes

  (3) waiting for a bandaid for (2) in order to propose changes for
      mitigating OOM "Genocide" attacks (as bad guys will find how to
      trigger OOM "Deadlock or Genocide" attacks from changes for
      mitigating OOM "Genocide" attacks)

I started posting to linux-mm ML in order to make forward progress
about (1) and (2). I don't want the memory allocation subsystem to
lock up an entire system by indefinitely disabling memory releasing
mechanism provided by the OOM killer.

> I've proposed a method of providing this forward progress guarantee
> for subsystems of arbitrary complexity, and this removes the
> dependency on the OOM killer for fowards allocation progress in such
> contexts (e.g. filesystems). We should be discussing how to
> implement that, not what bandaids we need to apply to the OOM
> killer. I want to fix the underlying problems, not push them under
> the OOM-killer bus...

I'm fine with that direction for new kernels provided that a simple
bandaid which can be backported to distributor kernels for making
OOM "Deadlock" attacks impossible is implemented. Therefore, I'm
discussing what bandaids we need to apply to the OOM killer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
