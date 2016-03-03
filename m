Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id B144A6B007E
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 05:30:08 -0500 (EST)
Received: by mail-io0-f170.google.com with SMTP id m184so22760839iof.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 02:30:08 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id m10si11306225igx.27.2016.03.03.02.30.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Mar 2016 02:30:08 -0800 (PST)
Subject: Re: [PATCH 0/3] OOM detection rework v4
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160302095056.GB26701@dhcp22.suse.cz>
	<CAAmzW4MoS8K1G+MqavXZAGSpOt92LqZcRzGdGgcop-kQS_tTXg@mail.gmail.com>
	<20160302140611.GI26686@dhcp22.suse.cz>
	<CAAmzW4NX2sooaghiqkFjFb3Yzazi6rGguQbDjiyWDnfBqP0a-A@mail.gmail.com>
	<20160303092634.GB26202@dhcp22.suse.cz>
In-Reply-To: <20160303092634.GB26202@dhcp22.suse.cz>
Message-Id: <201603031929.CCI95349.HOMQOOtJFFVLFS@I-love.SAKURA.ne.jp>
Date: Thu, 3 Mar 2016 19:29:47 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, js1304@gmail.com
Cc: iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, hughd@google.com, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com

Michal Hocko wrote:
> Sure we can be more intelligent and reset the counter if the
> feedback from compaction is optimistic and we are making some
> progress. This would be less hackish and the XXX comment points into
> that direction. For now I would like this to catch most loads reasonably
> and build better heuristics on top. I would like to do as much as
> possible to close the obvious regressions but I guess we have to expect
> there will be cases where the OOM fires and hasn't before and vice
> versa.

Aren't you forgetting that some people use panic_on_oom > 0 which means that
premature OOM killer invocation is fatal for them?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
