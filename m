Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E9DE06B0007
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 03:18:41 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id q8-v6so3689083wmc.2
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 00:18:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y5-v6sor2638536wrs.28.2018.07.05.00.18.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Jul 2018 00:18:40 -0700 (PDT)
Date: Thu, 5 Jul 2018 09:18:39 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: kernel BUG at mm/gup.c:LINE!
Message-ID: <20180705071839.GB30187@techadventures.net>
References: <000000000000fe4b15057024bacd@google.com>
 <da0f4abb-9401-cfac-6332-9086aadf67eb@I-love.SAKURA.ne.jp>
 <20180704111731.GJ22503@dhcp22.suse.cz>
 <FB141DA1-F8B8-4E9A-84E5-176B07463AEB@cs.rutgers.edu>
 <20180704121107.GL22503@dhcp22.suse.cz>
 <20180704151529.GA23317@techadventures.net>
 <20180705064335.GA32658@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180705064335.GA32658@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, syzbot <syzbot+5dcb560fe12aa5091c06@syzkaller.appspotmail.com>, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, mst@redhat.com, syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk, ying.huang@intel.com

 
> This is more than unexpected. The patch merely move the alignment check
> up. I will try to investigate some more but I am off for next four days
> and won't be online most of the time.
> 
> Btw. does the same happen if you keep do_brk helper and add the length
> sanitization there as well?

I will give it a try and I will let you know.

-- 
Oscar Salvador
SUSE L3
