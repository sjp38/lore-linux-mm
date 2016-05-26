Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 927CB6B007E
	for <linux-mm@kvack.org>; Wed, 25 May 2016 21:28:14 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w143so100280600oiw.3
        for <linux-mm@kvack.org>; Wed, 25 May 2016 18:28:14 -0700 (PDT)
Received: from mail-oi0-x22f.google.com (mail-oi0-x22f.google.com. [2607:f8b0:4003:c06::22f])
        by mx.google.com with ESMTPS id z5si7450526otb.104.2016.05.25.18.28.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 18:28:13 -0700 (PDT)
Received: by mail-oi0-x22f.google.com with SMTP id j1so101776716oih.3
        for <linux-mm@kvack.org>; Wed, 25 May 2016 18:28:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160525155122.GK20132@dhcp22.suse.cz>
References: <1464068266-27736-1-git-send-email-roy.qing.li@gmail.com>
	<20160525155122.GK20132@dhcp22.suse.cz>
Date: Thu, 26 May 2016 09:28:13 +0800
Message-ID: <CAJFZqHwYC_BbTNG=5=LYxo+6q6HadEMDkVTcZS1eCqXoD=6HnA@mail.gmail.com>
Subject: Re: [PATCH][V2] mm: memcontrol: fix the margin computation in mem_cgroup_margin
From: Li RongQing <roy.qing.li@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@virtuozzo.com>

On Wed, May 25, 2016 at 11:51 PM, Michal Hocko <mhocko@kernel.org> wrote:
> This is quite hard for me to grasp. What would you say about the
> following:
> "
> mem_cgroup_margin might return memory.limit - memory_count when
> the memsw.limit is in excess. This
> doesn't happen usually because we do not allow excess on hard limits and
> memory.limit <= memsw.limit but __GFP_NOFAIL charges can force the charge
> and cause the excess when no memory is really swapable (swap is full or
> no anonymous memory is left).


Sorry for my poor English, thanks for your description, hope it can be
into the log

-Roy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
