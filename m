Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id A17DD6B0260
	for <linux-mm@kvack.org>; Sat,  6 Jan 2018 22:42:48 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id 3so5847732plv.17
        for <linux-mm@kvack.org>; Sat, 06 Jan 2018 19:42:48 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id y72si6464819plh.393.2018.01.06.19.42.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 06 Jan 2018 19:42:47 -0800 (PST)
Subject: Re: Google Chrome cause locks held in system (kernel 4.15 rc2)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1515248235.17396.4.camel@gmail.com>
	<201801062352.EFF56799.HFFLOMOJOFSQtV@I-love.SAKURA.ne.jp>
	<1515252530.17396.16.camel@gmail.com>
	<201801070048.JAE30243.MLQOtHVFOOFJFS@I-love.SAKURA.ne.jp>
	<1515259453.17396.17.camel@gmail.com>
In-Reply-To: <1515259453.17396.17.camel@gmail.com>
Message-Id: <201801071242.CCD05710.HFFVQJMtOOFOSL@I-love.SAKURA.ne.jp>
Date: Sun, 7 Jan 2018 12:42:40 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mikhail.v.gavrilov@gmail.com
Cc: mhocko@kernel.org, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-mm@kvack.org

mikhail wrote:
> Thanks, I investigated the code of new version udplogger. I understood
> why it is not subject to the problems described above. Because it uses
> one file for all clients. The old version tried to create a separate
> file for each client.
> 
> Why you not using git hosting?

Because I don't have my git trees. svn is sufficient.

> Old version is quickly searchable by google.

Using old version is fine.
What you are seeing is a bug which exists in kohsuke's version.

> Look here it's second place in search results:
> https://imgur.com/a/IKHY8
> And new version is impossible to find in searching engine, it's so sad.
> 

In my search result, my version is printed first.
URL of my version is explicitly shown in the LCJ2014-en_0.pdf file.
I can't afford investigating modified/variant versions which are called "udplogger".
I don't have control for preventing modified/variant versions from appearing. ;-)

Anyway, please report when you succeeded to reproduce slowdown problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
