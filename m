Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id D2C9F6B025E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 09:22:58 -0400 (EDT)
Received: by mail-pf0-f182.google.com with SMTP id n5so311544839pfn.2
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 06:22:58 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id g4si2386126pat.65.2016.03.22.06.22.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Mar 2016 06:22:58 -0700 (PDT)
Date: Tue, 22 Mar 2016 14:22:49 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 1/9] sched: add schedule_timeout_idle()
Message-ID: <20160322132249.GP6344@twins.programming.kicks-ass.net>
References: <1458644426-22973-1-git-send-email-mhocko@kernel.org>
 <1458644426-22973-2-git-send-email-mhocko@kernel.org>
 <20160322122345.GN6344@twins.programming.kicks-ass.net>
 <20160322123314.GD10381@dhcp22.suse.cz>
 <20160322125113.GO6344@twins.programming.kicks-ass.net>
 <20160322130822.GF10381@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160322130822.GF10381@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@elte.hu>

On Tue, Mar 22, 2016 at 02:08:23PM +0100, Michal Hocko wrote:
> On Tue 22-03-16 13:51:13, Peter Zijlstra wrote:
> If that sounds like a more appropriate plan I won't object. I can simply
> change my patch to do __set_current_state and schedule_timeout.

I dunno, I just think these wrappers are silly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
