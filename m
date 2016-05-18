Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id C939A6B0262
	for <linux-mm@kvack.org>; Wed, 18 May 2016 03:39:07 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id i75so89077803ioa.3
        for <linux-mm@kvack.org>; Wed, 18 May 2016 00:39:07 -0700 (PDT)
Received: from mail-oi0-x22e.google.com (mail-oi0-x22e.google.com. [2607:f8b0:4003:c06::22e])
        by mx.google.com with ESMTPS id n186si2843229oih.70.2016.05.18.00.39.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 May 2016 00:39:07 -0700 (PDT)
Received: by mail-oi0-x22e.google.com with SMTP id x19so63718005oix.2
        for <linux-mm@kvack.org>; Wed, 18 May 2016 00:39:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160518073253.GC21654@dhcp22.suse.cz>
References: <1463556255-31892-1-git-send-email-roy.qing.li@gmail.com>
	<20160518073253.GC21654@dhcp22.suse.cz>
Date: Wed, 18 May 2016 15:39:07 +0800
Message-ID: <CAJFZqHw0HZ_H8Ax0TSn_Aor41DL4U9Yzx9+Oz342O6Y0nub8HQ@mail.gmail.com>
Subject: Re: [PATCH] mm: memcontrol: fix the return in mem_cgroup_margin
From: Li RongQing <roy.qing.li@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com

On Wed, May 18, 2016 at 3:32 PM, Michal Hocko <mhocko@kernel.org> wrote:
> Or have you seen any real problem with this code path?


not;
I read the codes, think it is more reasonable to set margin to 0 here

-Roy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
