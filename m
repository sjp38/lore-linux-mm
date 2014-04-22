Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9AB536B0038
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 07:54:31 -0400 (EDT)
Received: by mail-ie0-f181.google.com with SMTP id tp5so4821914ieb.26
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 04:54:31 -0700 (PDT)
Received: from mail-ie0-x22f.google.com (mail-ie0-x22f.google.com [2607:f8b0:4001:c03::22f])
        by mx.google.com with ESMTPS id nv8si15133466icc.39.2014.04.22.04.54.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 04:54:31 -0700 (PDT)
Received: by mail-ie0-f175.google.com with SMTP id to1so4907166ieb.6
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 04:54:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140422114838.GK29311@dhcp22.suse.cz>
References: <1397861935-31595-1-git-send-email-nasa4836@gmail.com>
 <20140422094759.GC29311@dhcp22.suse.cz> <CAHz2CGWrk3kuR=BLt2vT-8gxJVtJcj6h17ase9=1CoWXwK6a3w@mail.gmail.com>
 <20140422103420.GI29311@dhcp22.suse.cz> <CAHz2CGUZyv-dvUUoSi2Vk_vgPAMqRN4yEg4F4XsKQ8udHeo2bQ@mail.gmail.com>
 <20140422114838.GK29311@dhcp22.suse.cz>
From: Jianyu Zhan <nasa4836@gmail.com>
Date: Tue, 22 Apr 2014 19:53:50 +0800
Message-ID: <CAHz2CGXETcRq3cBDvkPm8JKcRA4qkhJefxz_VsmMouqfsGN5SA@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm/memcontrol.c: remove meaningless while loop in mem_cgroup_iter()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, kamezawa.hiroyu@jp.fujitsu.com, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Apr 22, 2014 at 7:48 PM, Michal Hocko <mhocko@suse.cz> wrote:
> Dunno, this particular case is more explicit but it is also uglier so I
> do not think this is an overall improvement. I would rather keep the
> current state unless the change either simplifies the generated code
> or it is much better to read.

hmm, I agree.  I will give it more thinking.

Seem this has been merged into -mm.  Andrew, please drop it!

Thanks,
Jianyu Zhan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
