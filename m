Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id A33366B0003
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 08:13:54 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id 22-v6so753988oix.0
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 05:13:54 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a204-v6sor467012oif.12.2018.07.17.05.13.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Jul 2018 05:13:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180717112515.GE7193@dhcp22.suse.cz>
References: <20180712172942.10094-1-hannes@cmpxchg.org> <20180716155745.10368-1-drake@endlessm.com>
 <20180717112515.GE7193@dhcp22.suse.cz>
From: Daniel Drake <drake@endlessm.com>
Date: Tue, 17 Jul 2018 07:13:52 -0500
Message-ID: <CAD8Lp45W00ga-P-nb6iytgSGW4xwSzmaTHA87DOvSotN0S2edw@mail.gmail.com>
Subject: Re: [PATCH 0/10] psi: pressure stall information for CPU, memory, and
 IO v2
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: hannes@cmpxchg.org, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Linux Upstreaming Team <linux@endlessm.com>, linux-block@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Vinayak Menon <vinmenon@codeaurora.org>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com

On Tue, Jul 17, 2018 at 6:25 AM, Michal Hocko <mhocko@kernel.org> wrote:
> Yes this is really unfortunate. One thing that could help would be to
> consider a trashing level during the reclaim (get_scan_count) to simply
> forget about LRUs which are constantly refaulting pages back. We already
> have the infrastructure for that. We just need to plumb it in.

Can you go into a bit more detail about that infrastructure and how we
might detect which pages are being constantly refaulted? I'm
interested in spending a few hours on this topic to see if I can come
up with anything.

Thanks
Daniel
