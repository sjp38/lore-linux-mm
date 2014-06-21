Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 08DFB6B0035
	for <linux-mm@kvack.org>; Sat, 21 Jun 2014 22:40:43 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y10so4281890pdj.5
        for <linux-mm@kvack.org>; Sat, 21 Jun 2014 19:40:43 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id tp10si16013604pbc.170.2014.06.21.19.40.42
        for <linux-mm@kvack.org>;
        Sat, 21 Jun 2014 19:40:42 -0700 (PDT)
Date: Sun, 22 Jun 2014 02:40:41 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [mmotm:master 188/230] fs/jffs2/debug.h:69:3: note: in expansion
 of macro 'pr_debug'
Message-ID: <20140621184041.GA10854@localhost>
References: <53a3e4f6.LlTrbyV58fY2TrZa%fengguang.wu@intel.com>
 <20140620132904.ec7eced87ff449625ad10d78@linux-foundation.org>
 <CAE9FiQVrOgEcP7wQhLtZZQ3yJ+gbYSE23_UYxJ2GKEWHU=GmWg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAE9FiQVrOgEcP7wQhLtZZQ3yJ+gbYSE23_UYxJ2GKEWHU=GmWg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

Hi Yinghai,

> Hi Fenguang,
> 
> Is rest robot going to sweep all new added branches in kernel.org git?

I need to manually add git tree URLs to the test pool. After that, the
robot will auto sweep all new added branches in the monitored git trees.

Your tree is already in the test pool:

git://git.kernel.org/pub/scm/linux/kernel/git/yinghai/linux-yinghai.git

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
