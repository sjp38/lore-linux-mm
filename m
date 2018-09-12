Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id C0B438E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 03:59:04 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id u74-v6so1332852oie.16
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 00:59:04 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id v64-v6si194965oie.317.2018.09.12.00.59.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 00:59:02 -0700 (PDT)
Message-Id: <201809120758.w8C7wrCN068547@www262.sakura.ne.jp>
Subject: Re: [RFC PATCH 0/3] rework mmap-exit vs. =?ISO-2022-JP?B?b29tX3JlYXBlciBo?=
 =?ISO-2022-JP?B?YW5kb3Zlcg==?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Wed, 12 Sep 2018 16:58:53 +0900
References: <201809120306.w8C36JbS080965@www262.sakura.ne.jp> <20180912071842.GY10951@dhcp22.suse.cz>
In-Reply-To: <20180912071842.GY10951@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>

Michal Hocko wrote:
> OK, I will fold the following to the patch

OK. But at that point, my patch which tries to wait for reclaimed memory
to be re-allocatable addresses a different problem which you are refusing.



By the way, is it guaranteed that vma->vm_ops->close(vma) in remove_vma() never
sleeps? Since remove_vma() has might_sleep() since 2005, and that might_sleep()
predates the git history, I don't know what that ->close() would do.

Anyway, please fix free_pgd_range() crash in this patchset.
