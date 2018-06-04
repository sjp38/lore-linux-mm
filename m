Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0233C6B0003
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 02:52:42 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id v12-v6so3941609wmc.1
        for <linux-mm@kvack.org>; Sun, 03 Jun 2018 23:52:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g3-v6si7617626edl.312.2018.06.03.23.52.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 03 Jun 2018 23:52:40 -0700 (PDT)
Date: Mon, 4 Jun 2018 08:52:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v7 2/2] Refactor part of the oom report in dump_header
Message-ID: <20180604065238.GE19202@dhcp22.suse.cz>
References: <1527940734-35161-1-git-send-email-ufo19890607@gmail.com>
 <1527940734-35161-2-git-send-email-ufo19890607@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1527940734-35161-2-git-send-email-ufo19890607@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ufo19890607@gmail.com
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, yuzhoujian <yuzhoujian@didichuxing.com>

On Sat 02-06-18 19:58:52, ufo19890607@gmail.com wrote:
> From: yuzhoujian <yuzhoujian@didichuxing.com>
> 
> The dump_header does not print the memcg's name when the system
> oom happened, so users cannot locate the certain container which
> contains the task that has been killed by the oom killer.
> 
> I follow the advices of David Rientjes and Michal Hocko, and refactor
> part of the oom report in a backwards compatible way. After this patch,
> users can get the memcg's path from the oom report and check the certain
> container more quickly.

I have earlier suggested that you split this into two parts. One to add
the missing information and the later to convert it to a single printk
output. Reducing the overhead from PATH_MAX to NAME_MAX is a good step
but it still really begs an example why we really insist on a single
printk and that should be in its own changelog.

Sorry if that was not clear previously.
-- 
Michal Hocko
SUSE Labs
