Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id AF4E66B0005
	for <linux-mm@kvack.org>; Wed, 18 May 2016 21:44:54 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id dh6so112554772obb.1
        for <linux-mm@kvack.org>; Wed, 18 May 2016 18:44:54 -0700 (PDT)
Received: from mail-oi0-x231.google.com (mail-oi0-x231.google.com. [2607:f8b0:4003:c06::231])
        by mx.google.com with ESMTPS id l69si4727145oib.206.2016.05.18.18.44.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 May 2016 18:44:54 -0700 (PDT)
Received: by mail-oi0-x231.google.com with SMTP id x19so106151125oix.2
        for <linux-mm@kvack.org>; Wed, 18 May 2016 18:44:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160518073253.GC21654@dhcp22.suse.cz>
References: <1463556255-31892-1-git-send-email-roy.qing.li@gmail.com>
	<20160518073253.GC21654@dhcp22.suse.cz>
Date: Thu, 19 May 2016 09:44:53 +0800
Message-ID: <CAJFZqHwFtZa-Ec_0bie6ORTrgoW1kqGsq49-=ojsT-uyNUBhwg@mail.gmail.com>
Subject: Re: [PATCH] mm: memcontrol: fix the return in mem_cgroup_margin
From: Li RongQing <roy.qing.li@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, vdavydov@virtuozzo.com

On Wed, May 18, 2016 at 3:32 PM, Michal Hocko <mhocko@kernel.org> wrote:
> count should always be smaller than memsw.limit (this is a hard limit).
> Even if we have some temporary breach then the code should work as
> expected because margin is initialized to 0 and memsw.limit >= limit.

is it possible for this case? for example

memory count is 500, memory limit is 600; the margin is set to 100 firstly,
then check memory+swap limit, its count(1100) is bigger than its limit(1000),
then the margin 100 is returned wrongly.


-Roy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
