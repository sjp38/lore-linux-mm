Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 2FBBA6B0103
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 07:27:16 -0400 (EDT)
Date: Thu, 4 Oct 2012 13:27:12 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: -mm git tree updated for 3.6 major release
Message-ID: <20121004112712.GC27536@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>

Hi,
JFYI a new branch since-3.6 has been created for -mm tree at
git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
It is based on v3.6 with the current 2012-10-03-16-21 mmots tree.
I will regurarly merge:
- for-3.7-hierarchy branch from git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git
- slab/common-for-cgroup branch from git://git.kernel.org/pub/scm/linux/kernel/git/penberg/linux.git

>From now on I am deprecating the original github tree
(https://github.com/mstsxfx/memcg-devel.git) and won't update it unless
there is something wrong with the korg.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
