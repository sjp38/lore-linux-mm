Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2F1C36B0038
	for <linux-mm@kvack.org>; Sat,  6 Jan 2018 12:24:19 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id y8so1559673lfj.1
        for <linux-mm@kvack.org>; Sat, 06 Jan 2018 09:24:19 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m25sor682249lfc.55.2018.01.06.09.24.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 06 Jan 2018 09:24:17 -0800 (PST)
Message-ID: <1515259453.17396.17.camel@gmail.com>
Subject: Re: Google Chrome cause locks held in system (kernel 4.15 rc2)
From: mikhail <mikhail.v.gavrilov@gmail.com>
Date: Sat, 06 Jan 2018 22:24:13 +0500
In-Reply-To: <201801070048.JAE30243.MLQOtHVFOOFJFS@I-love.SAKURA.ne.jp>
References: <1512963298.23718.15.camel@gmail.com>
	 <201712110348.vBB3mSFZ068689@www262.sakura.ne.jp>
	 <1515248235.17396.4.camel@gmail.com>
	 <201801062352.EFF56799.HFFLOMOJOFSQtV@I-love.SAKURA.ne.jp>
	 <1515252530.17396.16.camel@gmail.com>
	 <201801070048.JAE30243.MLQOtHVFOOFJFS@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-mm@kvack.org

On Sun, 2018-01-07 at 00:48 +0900, Tetsuo Handa wrote:
> mikhail wrote:
> > > > Also i fixed two segfault:
> > > > 
> > > > 1) When send two messages in one second from different hosts or
> > > > ports.
> > > > For reproduce just run
> > > > "echo test > /dev/udp/127.0.0.1/6666 && echo test >
> > > > /dev/udp/127.0.0.1/6666"
> > > > in console.
> > > 
> > > I can't observe such problem.
> > > udplogger is ready to concurrently receive from multiple sources.
> > 
> > 
> > Too strange because this condition
> > https://github.com/kohsuke/udplogger/blob/master/udplogger.c#L82
> > do not allow open two file in one second.
> 
> Oh, you got your copy of modified version of old version.
> 
> Please use original latest version at
> https://osdn.net/projects/akari/scm/svn/tree/head/branches/udplogger/
>  .


Thanks, I investigated the code of new version udplogger. I understood
why it is not subject to the problems described above. Because it uses
one file for all clients. The old version tried to create a separate
file for each client.

Why you not using git hosting?
Old version is quickly searchable by google.
Look here it's second place in search results:
https://imgur.com/a/IKHY8
And new version is impossible to find in searching engine, it's so sad.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
