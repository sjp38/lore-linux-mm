Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0B84682963
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 17:58:09 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id n128so21487086pfn.3
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 14:58:09 -0800 (PST)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id l84si11982788pfb.158.2016.02.03.14.58.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 14:58:08 -0800 (PST)
Received: by mail-pf0-x231.google.com with SMTP id w123so21770816pfb.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 14:58:08 -0800 (PST)
Date: Wed, 3 Feb 2016 14:58:06 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 0/3] OOM detection rework v4
In-Reply-To: <20160203132718.GI6757@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1602031457120.10331@chino.kir.corp.google.com>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org> <20160203132718.GI6757@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, 3 Feb 2016, Michal Hocko wrote:

> Hi,
> this thread went mostly quite. Are all the main concerns clarified?
> Are there any new concerns? Are there any objections to targeting
> this for the next merge window?

Did we ever figure out what was causing the oom killer to be called much 
earlier in Tetsuo's http://marc.info/?l=linux-kernel&m=145096089726481 and
http://marc.info/?l=linux-kernel&m=145130454913757 ?  I'd like to take a 
look at the patch(es) that fixed it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
