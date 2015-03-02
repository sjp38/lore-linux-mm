Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 7A6AC6B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 15:44:28 -0500 (EST)
Received: by pdjg10 with SMTP id g10so42425331pdj.1
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 12:44:28 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id a2si17843501pdf.154.2015.03.02.12.44.27
        for <linux-mm@kvack.org>;
        Mon, 02 Mar 2015 12:44:27 -0800 (PST)
Date: Mon, 02 Mar 2015 15:44:24 -0500 (EST)
Message-Id: <20150302.154424.30182050492471222.davem@davemloft.net>
Subject: Re: [RFC 3/4] sparc: remove __GFP_NOFAIL reuquirement
From: David Miller <davem@davemloft.net>
In-Reply-To: <20150302203304.GA20513@dhcp22.suse.cz>
References: <1425304483-7987-4-git-send-email-mhocko@suse.cz>
	<20150302.150405.2072800922470200977.davem@davemloft.net>
	<20150302203304.GA20513@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, rientjes@google.com, david@fromorbit.com, tytso@mit.edu, mgorman@suse.de, penguin-kernel@I-love.SAKURA.ne.jp, sparclinux@vger.kernel.org, vipul@chelsio.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org

From: Michal Hocko <mhocko@suse.cz>
Date: Mon, 2 Mar 2015 21:33:04 +0100

> On Mon 02-03-15 15:04:05, David S. Miller wrote:
>> From: Michal Hocko <mhocko@suse.cz>
>> Date: Mon,  2 Mar 2015 14:54:42 +0100
>> 
>> > mdesc_kmalloc is currently requiring __GFP_NOFAIL allocation although it
>> > seems that the allocation failure is handled by all callers (via
>> > mdesc_alloc). __GFP_NOFAIL is a strong liability for the memory
>> > allocator and so the users are discouraged to use the flag unless the
>> > allocation failure is really a nogo. Drop the flag here as this doesn't
>> > seem to be the case.
>> > 
>> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
>> 
>> It is a serious failure.
>> 
>> If we miss an MDESC update due to this allocation failure, the update
>> is not an event which gets retransmitted so we will lose the updated
>> machine description forever.
>> 
>> We really need this allocation to succeed.
> 
> OK, thanks for the clarification. This wasn't clear from the commit
> which has introduced this code. I will drop this patch. Would you
> accept something like the following instead?

Sure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
