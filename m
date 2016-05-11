Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f198.google.com (mail-ig0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 325ED6B0253
	for <linux-mm@kvack.org>; Wed, 11 May 2016 09:39:33 -0400 (EDT)
Received: by mail-ig0-f198.google.com with SMTP id kj7so83317371igb.3
        for <linux-mm@kvack.org>; Wed, 11 May 2016 06:39:33 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id bg5si8880554igb.68.2016.05.11.06.39.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 May 2016 06:39:32 -0700 (PDT)
Date: Wed, 11 May 2016 15:39:28 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: x86_64 Question: Are concurrent IPI requests safe?
Message-ID: <20160511133928.GF3192@twins.programming.kicks-ass.net>
References: <201605061958.HHG48967.JVFtSLFQOFOOMH@I-love.SAKURA.ne.jp>
 <201605092354.AHF82313.FtQFOMVOFJLOSH@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.11.1605091853130.3540@nanos>
 <201605112219.HEB64012.FLQOFMJOVOtFHS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201605112219.HEB64012.FLQOFMJOVOtFHS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: tglx@linutronix.de, mingo@kernel.org, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 11, 2016 at 10:19:16PM +0900, Tetsuo Handa wrote:
> [  180.434659] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013

can you reproduce on real hardware?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
