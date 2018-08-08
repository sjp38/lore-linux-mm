Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id B1D6F6B0007
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 05:46:51 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id o18-v6so1329819qtm.11
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 02:46:51 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00107.outbound.protection.outlook.com. [40.107.0.107])
        by mx.google.com with ESMTPS id 14-v6si3841493qkk.312.2018.08.08.02.46.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 Aug 2018 02:46:50 -0700 (PDT)
Subject: Re: [PATCH RFC 01/10] rcu: Make CONFIG_SRCU unconditionally enabled
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
 <153365625652.19074.8434946780002619802.stgit@localhost.localdomain>
 <20180808110542.6df3f48f@canb.auug.org.au>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <a1ca4c67-aa03-7381-151e-e7d85e402e78@virtuozzo.com>
Date: Wed, 8 Aug 2018 12:46:39 +0300
MIME-Version: 1.0
In-Reply-To: <20180808110542.6df3f48f@canb.auug.org.au>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: akpm@linux-foundation.org, gregkh@linuxfoundation.org, rafael@kernel.org, viro@zeniv.linux.org.uk, darrick.wong@oracle.com, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, hughd@google.com, shuah@kernel.org, robh@kernel.org, ulf.hansson@linaro.org, aspriel@gmail.com, vivek.gautam@codeaurora.org, robin.murphy@arm.com, joe@perches.com, heikki.krogerus@linux.intel.com, vdavydov.dev@gmail.com, mhocko@suse.com, chris@chris-wilson.co.uk, penguin-kernel@I-love.SAKURA.ne.jp, aryabinin@virtuozzo.com, willy@infradead.org, ying.huang@intel.com, shakeelb@google.com, jbacik@fb.com, mingo@kernel.org, mhiramat@kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On 08.08.2018 04:05, Stephen Rothwell wrote:
> Hi Kirill,
> 
> On Tue, 07 Aug 2018 18:37:36 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>>
>> This patch kills all CONFIG_SRCU defines and
>> the code under !CONFIG_SRCU.
>>
>> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
>> ---
>>  drivers/base/core.c                                |   42 --------------------
>>  include/linux/device.h                             |    2 -
>>  include/linux/rcutiny.h                            |    4 --
>>  include/linux/srcu.h                               |    5 --
>>  kernel/notifier.c                                  |    3 -
>>  kernel/rcu/Kconfig                                 |   12 +-----
>>  kernel/rcu/tree.h                                  |    5 --
>>  kernel/rcu/update.c                                |    4 --
>>  .../selftests/rcutorture/doc/TREE_RCU-kconfig.txt  |    5 --
>>  9 files changed, 3 insertions(+), 79 deletions(-)
> 
> You left quite a few "select SRCU" statements scattered across Kconfig
> files:
> 
> $ git grep -l 'select SRCU' '*Kconfig*'
> arch/arm/kvm/Kconfig
> arch/arm64/kvm/Kconfig
> arch/mips/kvm/Kconfig
> arch/powerpc/kvm/Kconfig
> arch/s390/kvm/Kconfig
> arch/x86/Kconfig
> arch/x86/kvm/Kconfig
> block/Kconfig
> drivers/clk/Kconfig
> drivers/cpufreq/Kconfig
> drivers/dax/Kconfig
> drivers/devfreq/Kconfig
> drivers/hwtracing/stm/Kconfig
> drivers/md/Kconfig
> drivers/net/Kconfig
> drivers/opp/Kconfig
> fs/btrfs/Kconfig
> fs/notify/Kconfig
> fs/quota/Kconfig
> init/Kconfig
> kernel/rcu/Kconfig
> kernel/rcu/Kconfig.debug
> mm/Kconfig
> security/tomoyo/Kconfig

Yeah, thanks, Stephen.
