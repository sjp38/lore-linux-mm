Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3245F6B0036
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 10:02:51 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id fb4so8399298wid.5
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 07:02:50 -0700 (PDT)
Received: from mail-we0-x235.google.com (mail-we0-x235.google.com [2a00:1450:400c:c03::235])
        by mx.google.com with ESMTPS id yw4si2823876wjc.94.2014.09.25.07.02.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Sep 2014 07:02:49 -0700 (PDT)
Received: by mail-we0-f181.google.com with SMTP id w61so6056890wes.26
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 07:02:49 -0700 (PDT)
Date: Thu, 25 Sep 2014 16:02:46 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [linux-next] mm/debug.c compile failure with CONFIG_MEMCG not set
Message-ID: <20140925140246.GC11080@dhcp22.suse.cz>
References: <CALLJCT0YKkg=PZN1i4eOEWdJoLE8oAyTAk0OmRHLOGRstqk4MQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALLJCT0YKkg=PZN1i4eOEWdJoLE8oAyTAk0OmRHLOGRstqk4MQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masanari Iida <standby24x7@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, sasha.levin@oracle.com, linux-mm@kvack.org

On Thu 25-09-14 22:55:24, Masanari Iida wrote:
> As of linux-next 20140925, if I don't set CONFIG_MEMCG,
> the compile failed with following error.
> 
> mm/debug.c: In function a??dump_mma??:
> mm/debug.c:169:1183: error: a??const struct mm_structa?? has no member named a??ownera??
>   pr_emerg("mm %p mmap %p seqnum %d task_size %lu\n"
> 
> make[1]: *** [mm/debug.o] Error 1
> 
> If I set CONFIG_MEMCG, the compile succeed.
> 
> Reported-by: Masanari Iida <standby24x7@gmail.com>

This is already fixed in Andrew's tree:
http://marc.info/?l=linux-mm&m=141146435524579&w=2

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
