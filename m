Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 013D26B0007
	for <linux-mm@kvack.org>; Thu,  3 May 2018 14:02:48 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id j6-v6so12461994pgn.7
        for <linux-mm@kvack.org>; Thu, 03 May 2018 11:02:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g2-v6sor84979pgf.344.2018.05.03.11.02.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 May 2018 11:02:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180502224437.18fe3ebb9e6955f321638f82@linux-foundation.org>
References: <20180503041450.pq2njvkssxtay64o@shao2-debian> <20180502212735.7660515ac03cf61630f5ff6b@linux-foundation.org>
 <CAM_iQpVDtrGCqd7NQ1vJXTuLMdz=GwbnN77vdkmY+PxtFmKHTw@mail.gmail.com> <20180502224437.18fe3ebb9e6955f321638f82@linux-foundation.org>
From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 3 May 2018 11:02:26 -0700
Message-ID: <CAM_iQpWzDHzKw0wa8gF7BZbgs4fa=zrdamr+_74oyWvaGzrcAQ@mail.gmail.com>
Subject: Re: [lkp-robot] 486ad79630 [ 15.532543] BUG: unable to handle kernel
 NULL pointer dereference at 0000000000000004
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kernel test robot <lkp@intel.com>, kernel test robot <shun.hao@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, LKP <lkp@01.org>, David Miller <davem@davemloft.net>, Linux Kernel Network Developers <netdev@vger.kernel.org>

On Wed, May 2, 2018 at 10:44 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 2 May 2018 21:58:25 -0700 Cong Wang <xiyou.wangcong@gmail.com> wrote:
>
>> On Wed, May 2, 2018 at 9:27 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
>> >
>> > So it's saying that something which got committed into Linus's tree
>> > after 4.17-rc3 has caused a NULL deref in
>> > sock_release->llc_ui_release+0x3a/0xd0
>>
>> Do you mean it contains commit 3a04ce7130a7
>> ("llc: fix NULL pointer deref for SOCK_ZAPPED")?
>
> That was in 4.17-rc3 so if this report's bisection is correct, that
> patch is innocent.
>
> origin.patch (http://ozlabs.org/~akpm/mmots/broken-out/origin.patch)
> contains no changes to net/llc/af_llc.c so perhaps this crash is also
> occurring in 4.17-rc3 base.

The commit I pointed out is supposed to fix this bug...

Please let me know if it doesn't.
