Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5AB096B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 10:20:55 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id sr6so6057169wjb.2
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 07:20:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p26si974977wrp.329.2017.01.06.07.20.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Jan 2017 07:20:53 -0800 (PST)
Date: Fri, 6 Jan 2017 16:20:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: __GFP_REPEAT usage in fq_alloc_node
Message-ID: <20170106152052.GS5556@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <edumazet@google.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Eric,
I am currently checking kmalloc with vmalloc fallback users and convert
them to a new kvmalloc helper [1]. While I am adding a support for
__GFP_REPEAT to kvmalloc [2] I was wondering what is the reason to use
__GFP_REPEAT in fq_alloc_node in the first place. c3bd85495aef
("pkt_sched: fq: more robust memory allocation") doesn't mention
anything. Could you clarify this please?

Thanks!

[1] http://lkml.kernel.org/r/20170102133700.1734-1-mhocko@kernel.org
[2] http://lkml.kernel.org/r/20170104181229.GB10183@dhcp22.suse.cz
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
