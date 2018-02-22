Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 10C166B02CC
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 08:23:56 -0500 (EST)
Received: by mail-vk0-f70.google.com with SMTP id m190so2750036vkg.5
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 05:23:56 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j5sor39285vkb.200.2018.02.22.05.23.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Feb 2018 05:23:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180222130341.GF30681@dhcp22.suse.cz>
References: <CAKTCnz=rS14Ry7pOC2qiX5wEbRZCKwP_0u7_ncanoV18Gz9=AQ@mail.gmail.com>
 <20180222130341.GF30681@dhcp22.suse.cz>
From: Balbir Singh <bsingharora@gmail.com>
Date: Fri, 23 Feb 2018 00:23:53 +1100
Message-ID: <CAKTCnzmsEhMYnAOtN+BtN_6bEa=+fTRYSjB+OR9isfzRruwA_Q@mail.gmail.com>
Subject: Re: [LSF/MM ATTEND] Attend mm summit 2018
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: lsf-pc <lsf-pc@lists.linux-foundation.org>, linux-mm <linux-mm@kvack.org>

On Fri, Feb 23, 2018 at 12:03 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Thu 22-02-18 13:54:46, Balbir Singh wrote:
> [...]
>> 2. Memory cgroups - I don't see a pressing need for many new features,
>> but I'd like to see if we can revive some old proposals around virtual
>> memory limits
>
> Could you be more specific about usecase(s)?

I had for a long time a virtual memory limit controller in -mm tree.
The use case was to fail allocations as opposed to OOM'ing in the
worst case as we do with the cgroup memory limits (actual page usage
control). I did not push for it then since I got side-tracked. I'd
like to pursue a use case for being able to fail allocations as
opposed to OOM'ing on a per cgroup basis. I'd like to start the
discussion again.

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
