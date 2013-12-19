Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 190F56B0037
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 11:49:30 -0500 (EST)
Received: by mail-we0-f170.google.com with SMTP id w61so1369466wes.29
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 08:49:29 -0800 (PST)
Received: from mail-ea0-x235.google.com (mail-ea0-x235.google.com [2a00:1450:4013:c01::235])
        by mx.google.com with ESMTPS id ui5si1770818wjc.22.2013.12.19.08.49.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 19 Dec 2013 08:49:29 -0800 (PST)
Received: by mail-ea0-f181.google.com with SMTP id m10so597528eaj.26
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 08:49:28 -0800 (PST)
Date: Thu, 19 Dec 2013 17:49:25 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/4] Fix ebizzy performance regression due to X86 TLB
 range flush v2
Message-ID: <20131219164925.GA29546@gmail.com>
References: <1386964870-6690-1-git-send-email-mgorman@suse.de>
 <CA+55aFyNAigQqBk07xLpf0nkhZ_x-QkBYG8otRzsqg_8A2eg-Q@mail.gmail.com>
 <20131215155539.GM11295@suse.de>
 <20131216102439.GA21624@gmail.com>
 <20131216125923.GS11295@suse.de>
 <20131216134449.GA3034@gmail.com>
 <20131217092124.GV11295@suse.de>
 <20131217110051.GA27701@gmail.com>
 <20131219142405.GM11295@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131219142405.GM11295@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Alex Shi <alex.shi@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>


* Mel Gorman <mgorman@suse.de> wrote:

> [...]
> 
> Because we lack data on TLB range flush distributions I think we 
> should still go with the conservative choice for the TLB flush 
> shift. The worst case is really bad here and it's painfully obvious 
> on ebizzy.

So I'm obviously much in favor of this - I'd in fact suggest making 
the conservative choice on _all_ CPU models that have aggressive TLB 
range values right now, because frankly the testing used to pick those 
values does not look all that convincing to me.

I very much suspect that the problem goes wider than just IvyBridge 
CPUs ... it's just that few people put as much testing into it as you.

We can certainly get more aggressive in the future, subject to proper 
measurements.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
