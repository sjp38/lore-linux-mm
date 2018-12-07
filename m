Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B75EA8E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 17:14:24 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id o9so3492778pgv.19
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 14:14:24 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 144si3818582pga.322.2018.12.07.14.14.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Dec 2018 14:14:23 -0800 (PST)
Date: Fri, 7 Dec 2018 14:14:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [linux-next:master 6857/7074] htmldocs:
 drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c:251: warning: Function parameter or
 member 'range' not described in 'amdgpu_mn_invalidate_range_start_gfx'
Message-Id: <20181207141420.fd2afe4df9cc871a67adb82c@linux-foundation.org>
In-Reply-To: <201812061510.3O6pcsYS%fengguang.wu@intel.com>
References: <201812061510.3O6pcsYS%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: Jerome Glisse <jglisse@redhat.com>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>

On Thu, 6 Dec 2018 15:51:12 +0800 kbuild test robot <lkp@intel.com> wrote:

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   15814356aac416bea48544b76b761d8687b5a1e9
> commit: c3a8616c95df8ced5d1acd838dc7dc384cb5276b [6857/7074] mm/mmu_notifier: use structure for invalidate_range_start/end callback
> reproduce: make htmldocs

Thanks, I did this:

--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c~mm-mmu_notifier-use-structure-for-invalidate_range_start-end-callback-fix-fix
+++ a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
@@ -238,9 +238,7 @@ static void amdgpu_mn_invalidate_node(st
  * amdgpu_mn_invalidate_range_start_gfx - callback to notify about mm change
  *
  * @mn: our notifier
- * @mm: the mm this callback is about
- * @start: start of updated range
- * @end: end of updated range
+ * @range: mmu notifier context
  *
  * Block for operations on BOs to finish and mark pages as accessed and
  * potentially dirty.
_
