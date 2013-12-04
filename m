Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f51.google.com (mail-bk0-f51.google.com [209.85.214.51])
	by kanga.kvack.org (Postfix) with ESMTP id ECEE66B006E
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 17:29:51 -0500 (EST)
Received: by mail-bk0-f51.google.com with SMTP id 6so6819592bkj.38
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 14:29:51 -0800 (PST)
Date: Wed, 4 Dec 2013 17:29:43 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: 2e685cad5790 build warning
Message-ID: <20131204222943.GC21724@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Glauber Costa <glommer@gmail.com>, netdev@vger.kernel.org, linux-mm@kvack.org, linux-kernel@kvack.org

Hi Eric,

commit 2e685cad57906e19add7189b5ff49dfb6aaa21d3
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Sat Oct 19 16:26:19 2013 -0700

    tcp_memcontrol: Kill struct tcp_memcontrol
    
    Replace the pointers in struct cg_proto with actual data fields and kill
    struct tcp_memcontrol as it is not fully redundant.
    
    This removes a confusing, unnecessary layer of abstraction.
    
    Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

triggers a build warning because it removed the only reference to a
function but not the function itself:

linux/net/ipv4/tcp_memcontrol.c:9:13: warning: a??memcg_tcp_enter_memory_pressurea?? defined but not used [-Wunused-function]
 static void memcg_tcp_enter_memory_pressure(struct sock *sk)

I can not see from the changelog why this function is no longer used,
or who is supposed to now set cg_proto->memory_pressure which you
still initialize etc.  Either way, the current state does not seem to
make much sense.  The author would be the best person to double check
such changes, but he wasn't copied on your patch, so I copied him now.

Apologies if this has been brought up before, I could not find any
reference on LKML of either this patch or a report of this warning.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
