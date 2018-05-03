Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 18AAA6B0009
	for <linux-mm@kvack.org>; Thu,  3 May 2018 00:58:48 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id f19-v6so11445021pgv.4
        for <linux-mm@kvack.org>; Wed, 02 May 2018 21:58:48 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id ba12-v6sor5177723plb.10.2018.05.02.21.58.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 May 2018 21:58:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180502212735.7660515ac03cf61630f5ff6b@linux-foundation.org>
References: <20180503041450.pq2njvkssxtay64o@shao2-debian> <20180502212735.7660515ac03cf61630f5ff6b@linux-foundation.org>
From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 2 May 2018 21:58:25 -0700
Message-ID: <CAM_iQpVDtrGCqd7NQ1vJXTuLMdz=GwbnN77vdkmY+PxtFmKHTw@mail.gmail.com>
Subject: Re: [lkp-robot] 486ad79630 [ 15.532543] BUG: unable to handle kernel
 NULL pointer dereference at 0000000000000004
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kernel test robot <lkp@intel.com>, kernel test robot <shun.hao@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, LKP <lkp@01.org>, David Miller <davem@davemloft.net>, Linux Kernel Network Developers <netdev@vger.kernel.org>

On Wed, May 2, 2018 at 9:27 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
>
> So it's saying that something which got committed into Linus's tree
> after 4.17-rc3 has caused a NULL deref in
> sock_release->llc_ui_release+0x3a/0xd0

Do you mean it contains commit 3a04ce7130a7
("llc: fix NULL pointer deref for SOCK_ZAPPED")?
