Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 82C686B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 23:07:17 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 190so12421274iow.2
        for <linux-mm@kvack.org>; Mon, 23 May 2016 20:07:17 -0700 (PDT)
Received: from mail-oi0-x22c.google.com (mail-oi0-x22c.google.com. [2607:f8b0:4003:c06::22c])
        by mx.google.com with ESMTPS id q11si560014otb.49.2016.05.23.20.07.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 20:07:16 -0700 (PDT)
Received: by mail-oi0-x22c.google.com with SMTP id k23so6537117oih.0
        for <linux-mm@kvack.org>; Mon, 23 May 2016 20:07:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160523120620.GP2278@dhcp22.suse.cz>
References: <1463556255-31892-1-git-send-email-roy.qing.li@gmail.com>
	<20160518073253.GC21654@dhcp22.suse.cz>
	<CAJFZqHwFtZa-Ec_0bie6ORTrgoW1kqGsq49-=ojsT-uyNUBhwg@mail.gmail.com>
	<20160523103758.GB7917@esperanza>
	<20160523120620.GP2278@dhcp22.suse.cz>
Date: Tue, 24 May 2016 11:07:16 +0800
Message-ID: <CAJFZqHzwqjzRriawoP92_v2VYxamCiVg2QjGpP7mmL1A1f9Cnw@mail.gmail.com>
Subject: Re: [PATCH] mm: memcontrol: fix the return in mem_cgroup_margin
From: Li RongQing <roy.qing.li@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>

On Mon, May 23, 2016 at 8:06 PM, Michal Hocko <mhocko@kernel.org> wrote:
>
> Can we have updated patch with all this useful information in the
> changelog, please?


Ok, I will update this patch

-Roy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
