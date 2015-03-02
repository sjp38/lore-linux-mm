Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9AFC46B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 16:45:50 -0500 (EST)
Received: by padbj1 with SMTP id bj1so21350143pad.11
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 13:45:50 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id ni10si10902514pbc.149.2015.03.02.13.45.49
        for <linux-mm@kvack.org>;
        Mon, 02 Mar 2015 13:45:49 -0800 (PST)
Date: Mon, 02 Mar 2015 16:45:45 -0500 (EST)
Message-Id: <20150302.164545.1603268042858889224.davem@davemloft.net>
Subject: Re: [PATCH] sparc: clarify __GFP_NOFAIL allocation
From: David Miller <davem@davemloft.net>
In-Reply-To: <20150302213610.GA31974@dhcp22.suse.cz>
References: <20150302203304.GA20513@dhcp22.suse.cz>
	<20150302.154424.30182050492471222.davem@davemloft.net>
	<20150302213610.GA31974@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, rientjes@google.com, david@fromorbit.com, tytso@mit.edu, mgorman@suse.de, penguin-kernel@I-love.SAKURA.ne.jp, sparclinux@vger.kernel.org, vipul@chelsio.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org

From: Michal Hocko <mhocko@suse.cz>
Date: Mon, 2 Mar 2015 22:36:10 +0100

> 920c3ed74134 ([SPARC64]: Add basic infrastructure for MD add/remove
> notification.) has added __GFP_NOFAIL for the allocation request but
> it hasn't mentioned why is this strict requirement really needed.
> The code was handling an allocation failure and propagated it properly
> up the callchain so it is not clear why it is needed.
> 
> Dave has clarified the intention when I tried to remove the flag as not
> being necessary:
> "
> It is a serious failure.
> 
> If we miss an MDESC update due to this allocation failure, the update
> is not an event which gets retransmitted so we will lose the updated
> machine description forever.
> 
> We really need this allocation to succeed.
> "
> 
> So add a comment to clarify the nofail flag and get rid of the failure
> check because __GFP_NOFAIL allocation doesn't fail.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
