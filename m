Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B81C06B0269
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 06:22:40 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v3-v6so3345743pfd.18
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 03:22:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s6-v6si13025640pgr.602.2018.07.02.03.22.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 03:22:39 -0700 (PDT)
Date: Mon, 2 Jul 2018 12:22:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v11 2/2] Add the missing information in dump_header
Message-ID: <20180702102236.GE19043@dhcp22.suse.cz>
References: <1530376739-20459-1-git-send-email-ufo19890607@gmail.com>
 <1530376739-20459-2-git-send-email-ufo19890607@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1530376739-20459-2-git-send-email-ufo19890607@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ufo19890607@gmail.com
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, yuzhoujian@didichuxing.com

On Sun 01-07-18 00:38:59, ufo19890607@gmail.com wrote:
> From: yuzhoujian <yuzhoujian@didichuxing.com>
> 
> Add a new func mem_cgroup_print_oom_context to print missing information
> for the system-wide oom report which includes the oom memcg that has
> reached its limit, task memcg that contains the killed task.

A proper changelog should contain the motivation. It is trivial to see
what the patch does from the diff. The motivation is less clear. What
about the followig
"
The current oom report doesn't display victim's memcg context during the
global OOM situation. While this information is not strictly needed it
can be really usefule for containerized environments to see which
container has lost a process (+ add more arguments I am just guessing
from your not really specific statements). Now that we have a single
line for the oom context we can trivially add both the oom memcg (this
can be either global_oom or a specific memcg which hits its hard limits)
and task_memcg which is the victim's memcg.
"
-- 
Michal Hocko
SUSE Labs
