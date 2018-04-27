Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 863606B0003
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 09:03:25 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k16-v6so1278869wrh.6
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 06:03:25 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k89sor336465wmc.57.2018.04.27.06.03.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 27 Apr 2018 06:03:23 -0700 (PDT)
MIME-Version: 1.0
References: <20180425214307.159264-2-edumazet@google.com> <201804271455.cJQuTeDc%fengguang.wu@intel.com>
In-Reply-To: <201804271455.cJQuTeDc%fengguang.wu@intel.com>
From: Eric Dumazet <edumazet@google.com>
Date: Fri, 27 Apr 2018 13:03:11 +0000
Message-ID: <CANn89i+gKvxN1qZSrM8oG_jz-HYXt8iMRt_mpf6Rcx4-u0=WfA@mail.gmail.com>
Subject: Re: [PATCH v2 net-next 1/2] tcp: add TCP_ZEROCOPY_RECEIVE support for
 zerocopy receive
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Eric Dumazet <eric.dumazet@gmail.com>, Soheil Hassas Yeganeh <soheil@google.com>

On Fri, Apr 27, 2018 at 1:45 AM kbuild test robot <lkp@intel.com> wrote:

> Hi Eric,

> Thank you for the patch! Yet something to improve:

> [auto build test ERROR on net-next/master]

> url:
https://github.com/0day-ci/linux/commits/Eric-Dumazet/tcp-add-TCP_ZEROCOPY_RECEIVE-support-for-zerocopy-receive/20180427-122234
> config: sh-rsk7269_defconfig (attached as .config)
> compiler: sh4-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
> reproduce:
>          wget
https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O
~/bin/make.cross
>          chmod +x ~/bin/make.cross
>          # save the attached .config to linux build tree
>          make.cross ARCH=sh

> All errors (new ones prefixed by >>):

>     net/ipv4/tcp.o: In function `tcp_setsockopt':
> >> tcp.c:(.text+0x3f80): undefined reference to `zap_page_range'

I guess this tcp zerocopy stuff depends on CONFIG_MMU

Thanks.
