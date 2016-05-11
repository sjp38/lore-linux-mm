Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5464D6B0260
	for <linux-mm@kvack.org>; Wed, 11 May 2016 10:09:30 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id fk7so13119854obb.0
        for <linux-mm@kvack.org>; Wed, 11 May 2016 07:09:30 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id m20si5238744ita.72.2016.05.11.07.09.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 May 2016 07:09:29 -0700 (PDT)
Subject: Re: x86_64 Question: Are concurrent IPI requests safe?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201605061958.HHG48967.JVFtSLFQOFOOMH@I-love.SAKURA.ne.jp>
	<201605092354.AHF82313.FtQFOMVOFJLOSH@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.11.1605091853130.3540@nanos>
	<201605112219.HEB64012.FLQOFMJOVOtFHS@I-love.SAKURA.ne.jp>
	<20160511133928.GF3192@twins.programming.kicks-ass.net>
In-Reply-To: <20160511133928.GF3192@twins.programming.kicks-ass.net>
Message-Id: <201605112309.AGJ18252.tOFMFQOJFLSOVH@I-love.SAKURA.ne.jp>
Date: Wed, 11 May 2016 23:09:21 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org
Cc: tglx@linutronix.de, mingo@kernel.org, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Peter Zijlstra wrote:
> On Wed, May 11, 2016 at 10:19:16PM +0900, Tetsuo Handa wrote:
> > [  180.434659] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
> 
> can you reproduce on real hardware?
> 
Unfortunately, I don't have a real hardware to run development kernels.

My Linux environment is limited to 4 CPUs / 1024MB or 2048MB RAM running
as a VMware guest on Windows. Can somebody try KVM environment with
4 CPUs / 1024MB or 2048MB RAM whith partition only plain /dev/sda1
formatted as XFS?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
