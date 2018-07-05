Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 29A8C6B000D
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 09:41:01 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id p11-v6so4172124oih.17
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 06:41:01 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id s13-v6si2551876oih.381.2018.07.05.06.40.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jul 2018 06:40:59 -0700 (PDT)
Subject: Re: kernel BUG at mm/gup.c:LINE!
References: <000000000000fe4b15057024bacd@google.com>
 <da0f4abb-9401-cfac-6332-9086aadf67eb@I-love.SAKURA.ne.jp>
 <20180704111731.GJ22503@dhcp22.suse.cz>
 <FB141DA1-F8B8-4E9A-84E5-176B07463AEB@cs.rutgers.edu>
 <20180704121107.GL22503@dhcp22.suse.cz>
 <20180704151529.GA23317@techadventures.net>
 <20180705064335.GA32658@dhcp22.suse.cz>
 <20180705071839.GB30187@techadventures.net>
 <20180705123017.GA31959@techadventures.net>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <5dc83957-1b43-78cf-0f11-429f41cbc260@i-love.sakura.ne.jp>
Date: Thu, 5 Jul 2018 22:40:11 +0900
MIME-Version: 1.0
In-Reply-To: <20180705123017.GA31959@techadventures.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>, Michal Hocko <mhocko@kernel.org>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, syzbot <syzbot+5dcb560fe12aa5091c06@syzkaller.appspotmail.com>, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, mst@redhat.com, syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk, ying.huang@intel.com

On 2018/07/05 21:30, Oscar Salvador wrote:
> This boots and works with the reproducer:

Yes, this patch fixes the problem on x86_32.

> But I think that we should also add:

Yes, this patch also fixes the problem on x86_32.
