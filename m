Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id F044182F64
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 20:28:55 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so107039904igb.0
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 17:28:55 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id b65si12048215ioe.177.2015.10.27.17.28.54
        for <linux-mm@kvack.org>;
        Tue, 27 Oct 2015 17:28:54 -0700 (PDT)
Date: Tue, 27 Oct 2015 17:45:32 -0700 (PDT)
Message-Id: <20151027.174532.469361008055673315.davem@davemloft.net>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
From: David Miller <davem@davemloft.net>
In-Reply-To: <20151027164227.GB7749@cmpxchg.org>
References: <20151027154138.GA4665@cmpxchg.org>
	<20151027161554.GJ9891@dhcp22.suse.cz>
	<20151027164227.GB7749@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: mhocko@kernel.org, akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Tue, 27 Oct 2015 09:42:27 -0700

> On Tue, Oct 27, 2015 at 05:15:54PM +0100, Michal Hocko wrote:
>> > For now, something like this as a boot commandline?
>> > 
>> > cgroup.memory=nosocket
>> 
>> That would work for me.
> 
> Okay, then I'll go that route for the socket stuff.
> 
> Dave is that cool with you?

Depends upon the default.

Until the user configures something explicitly into the memory
controller, the networking bits should all evaluate to nothing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
