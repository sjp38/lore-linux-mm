Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1B5176B0005
	for <linux-mm@kvack.org>; Thu,  3 May 2018 01:44:41 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id w7so11445997pfd.9
        for <linux-mm@kvack.org>; Wed, 02 May 2018 22:44:41 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n3-v6si9139008pld.116.2018.05.02.22.44.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 22:44:39 -0700 (PDT)
Date: Wed, 2 May 2018 22:44:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [lkp-robot] 486ad79630 [ 15.532543] BUG: unable to handle
 kernel NULL pointer dereference at 0000000000000004
Message-Id: <20180502224437.18fe3ebb9e6955f321638f82@linux-foundation.org>
In-Reply-To: <CAM_iQpVDtrGCqd7NQ1vJXTuLMdz=GwbnN77vdkmY+PxtFmKHTw@mail.gmail.com>
References: <20180503041450.pq2njvkssxtay64o@shao2-debian>
	<20180502212735.7660515ac03cf61630f5ff6b@linux-foundation.org>
	<CAM_iQpVDtrGCqd7NQ1vJXTuLMdz=GwbnN77vdkmY+PxtFmKHTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Cc: kernel test robot <lkp@intel.com>, kernel test robot <shun.hao@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, LKP <lkp@01.org>, David Miller <davem@davemloft.net>, Linux Kernel Network Developers <netdev@vger.kernel.org>

On Wed, 2 May 2018 21:58:25 -0700 Cong Wang <xiyou.wangcong@gmail.com> wrote:

> On Wed, May 2, 2018 at 9:27 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > So it's saying that something which got committed into Linus's tree
> > after 4.17-rc3 has caused a NULL deref in
> > sock_release->llc_ui_release+0x3a/0xd0
> 
> Do you mean it contains commit 3a04ce7130a7
> ("llc: fix NULL pointer deref for SOCK_ZAPPED")?

That was in 4.17-rc3 so if this report's bisection is correct, that
patch is innocent.

origin.patch (http://ozlabs.org/~akpm/mmots/broken-out/origin.patch)
contains no changes to net/llc/af_llc.c so perhaps this crash is also
occurring in 4.17-rc3 base.
