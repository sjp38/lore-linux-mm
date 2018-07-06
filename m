Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 12CC46B0007
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 03:40:56 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id q8-v6so6364090wmc.2
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 00:40:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x3-v6sor3675670wrr.37.2018.07.06.00.40.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Jul 2018 00:40:54 -0700 (PDT)
Date: Fri, 6 Jul 2018 09:40:53 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: kernel BUG at mm/gup.c:LINE!
Message-ID: <20180706074053.GA8235@techadventures.net>
References: <000000000000fe4b15057024bacd@google.com>
 <da0f4abb-9401-cfac-6332-9086aadf67eb@I-love.SAKURA.ne.jp>
 <20180704111731.GJ22503@dhcp22.suse.cz>
 <FB141DA1-F8B8-4E9A-84E5-176B07463AEB@cs.rutgers.edu>
 <20180704121107.GL22503@dhcp22.suse.cz>
 <20180704151529.GA23317@techadventures.net>
 <20180705064335.GA32658@dhcp22.suse.cz>
 <20180705071839.GB30187@techadventures.net>
 <20180705123017.GA31959@techadventures.net>
 <20180706053545.GD32658@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180706053545.GD32658@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, syzbot <syzbot+5dcb560fe12aa5091c06@syzkaller.appspotmail.com>, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, mst@redhat.com, syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk, ying.huang@intel.com

> Reported-by: syzbot <syzbot+5dcb560fe12aa5091c06@syzkaller.appspotmail.com>
> [osalvador: fix up vm_brk_flags s@request@len@]
> Tested-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: stable
> Signed-off-by: Michal Hocko <mhocko@suse.com>

hi Michal,

I gave it another spin and it works for me.

FWIW:
Reviewed-by: Oscar Salvador <osalvador@suse.de>
-- 
Oscar Salvador
SUSE L3
