Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id D51846B02C7
	for <linux-mm@kvack.org>; Sat,  6 Jan 2018 10:48:20 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id y21so242920pll.22
        for <linux-mm@kvack.org>; Sat, 06 Jan 2018 07:48:20 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i2si5045823pgo.637.2018.01.06.07.48.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 06 Jan 2018 07:48:19 -0800 (PST)
Subject: Re: Google Chrome cause locks held in system (kernel 4.15 rc2)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1512963298.23718.15.camel@gmail.com>
	<201712110348.vBB3mSFZ068689@www262.sakura.ne.jp>
	<1515248235.17396.4.camel@gmail.com>
	<201801062352.EFF56799.HFFLOMOJOFSQtV@I-love.SAKURA.ne.jp>
	<1515252530.17396.16.camel@gmail.com>
In-Reply-To: <1515252530.17396.16.camel@gmail.com>
Message-Id: <201801070048.JAE30243.MLQOtHVFOOFJFS@I-love.SAKURA.ne.jp>
Date: Sun, 7 Jan 2018 00:48:13 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mikhail.v.gavrilov@gmail.com
Cc: mhocko@kernel.org, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-mm@kvack.org

mikhail wrote:
> > > Also i fixed two segfault:
> > > 
> > > 1) When send two messages in one second from different hosts or
> > > ports.
> > > For reproduce just run
> > > "echo test > /dev/udp/127.0.0.1/6666 && echo test >
> > > /dev/udp/127.0.0.1/6666"
> > > in console.
> > 
> > I can't observe such problem.
> > udplogger is ready to concurrently receive from multiple sources.
> 
> 
> Too strange because this condition
> https://github.com/kohsuke/udplogger/blob/master/udplogger.c#L82
> do not allow open two file in one second.

Oh, you got your copy of modified version of old version.

Please use original latest version at
https://osdn.net/projects/akari/scm/svn/tree/head/branches/udplogger/ .

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
