Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2242B6B02C3
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 01:14:53 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b20so3279225wmd.6
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 22:14:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f29si14306509wra.26.2017.06.26.22.14.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Jun 2017 22:14:51 -0700 (PDT)
Date: Tue, 27 Jun 2017 07:14:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Error in freeing memory with zone reclaimable always returning
 true.
Message-ID: <20170627051449.GA28072@dhcp22.suse.cz>
References: <CABXF_ACjD535xtk5_1MO6O8rdT+eudCn=GG0tM1ntEb6t1JO8w@mail.gmail.com>
 <20170626080019.GC11534@dhcp22.suse.cz>
 <1498482248.5348.7.camel@gmail.com>
 <20170626142730.GP11534@dhcp22.suse.cz>
 <1498538287.5692.3.camel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1498538287.5692.3.camel@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ivid Suvarna <ivid.suvarna@gmail.com>
Cc: linux-mm@kvack.org

On Mon 26-06-17 21:38:07, Ivid Suvarna wrote:
[...]
> Thanks Michal for the clarifications. One last thing, in suspend to ram
> or suspend to disk we freeze userspace processes. Is there any way to
> print the userspace processes that were freezed during
> suspend?i.e.,either process name or PID.

Well, try_to_freeze_tasks iterates over all tasks and checks whether
they are frozen (see freeze_task), so you can mimic that logic, although
you might need freezer_lock which is internal to the freezer. Also there
might tasks which have been frozen because of the freezer cgroup and it
is not clear whether you want to consider those as well.

Anyway I would recommend you to start a new email thread and involve
freezer maintainers to get a better info.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
