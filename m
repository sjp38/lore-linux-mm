Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id D25F26B0005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 10:58:31 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 68so14038161lfq.2
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:58:31 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id ji7si30334649wjb.247.2016.04.26.07.58.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 07:58:30 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id n3so5798567wmn.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:58:30 -0700 (PDT)
Date: Tue, 26 Apr 2016 16:58:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, oom_reaper: do not mmput synchronously from the
 oom reaper context
Message-ID: <20160426145828.GF20813@dhcp22.suse.cz>
References: <1461679470-8364-3-git-send-email-mhocko@kernel.org>
 <201604262233.UgQXNIir%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201604262233.UgQXNIir%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 26-04-16 22:18:22, kbuild test robot wrote:
> >> include/linux/mm_types.h:516:21: error: field 'async_put_work' has incomplete type
>      struct work_struct async_put_work;

My bad. We need to include <linux/workqueue.h> because we rely on the
include only indirectly which happened to work fine for most of my
configs - not so for allnoconfig, though. Please fold this into the
original patch or let me know and I will repost the full patch again.
---
