Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 991D86B0006
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 06:32:18 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v14so3649983pgq.11
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 03:32:18 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id a7-v6si988002plp.22.2018.03.29.03.32.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Mar 2018 03:32:17 -0700 (PDT)
Subject: Re: [lkp-robot] [mm]  67ffc906f8:WARNING:at_mm/filemap.c:#__warn_lock_page_from_reclaim_context
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201803181022.IAI30275.JOFOQMtFSHLFOV@I-love.SAKURA.ne.jp>
	<20180329070409.GF4172@yexl-desktop>
In-Reply-To: <20180329070409.GF4172@yexl-desktop>
Message-Id: <201803291932.AJH35913.JOQSFFtOLFOVHM@I-love.SAKURA.ne.jp>
Date: Thu, 29 Mar 2018 19:32:11 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xiaolong.ye@intel.com, lkp@01.org
Cc: kirill@shutemov.name, akpm@linux-foundation.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, mhocko@suse.com

kernel test robot wrote:
> FYI, we noticed the following commit (built with gcc-4.9):
> 
> commit: 67ffc906f8dee0e0433cad83dbdd198e5d1fc86f ("mm: Warn on lock_page() from reclaim context.")
> url: https://github.com/0day-ci/linux/commits/Tetsuo-Handa/mm-Warn-on-lock_page-from-reclaim-context/20180318-173622

Thanks. Already fixed in v4.16-rc7.

commit b3cd54b257ad95d344d121dc563d943ca39b0921
Author: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Date:   Thu Mar 22 16:17:35 2018 -0700

    mm/shmem: do not wait for lock_page() in shmem_unused_huge_shrink()

> [   60.850212] CPU: 0 PID: 221 Comm: sed Not tainted 4.16.0-rc4-00340-g67ffc90 #2
