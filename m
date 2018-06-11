Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E4B046B0005
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 03:25:27 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id j10-v6so6233531pgv.6
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 00:25:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o9-v6sor6551952pgr.390.2018.06.11.00.25.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Jun 2018 00:25:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180611070916.GB13364@dhcp22.suse.cz>
References: <201806111409.N4l80RQU%fengguang.wu@intel.com> <20180611070916.GB13364@dhcp22.suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 11 Jun 2018 09:25:05 +0200
Message-ID: <CACT4Y+aDpO2VLATSv5YJeS6gYe7eB_67Lq9hQ64+rs78YE5org@mail.gmail.com>
Subject: Re: [memcg:akpm/kcov 4/4] /tmp/ccMETRHQ.s:35: Error: .err encountered
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jun 11, 2018 at 9:09 AM, Michal Hocko <mhocko@suse.com> wrote:
> On Mon 11-06-18 14:57:10, kbuild test robot wrote:
>> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git akpm/kcov
>> head:   99027ccd1ec1b31fc74d63df2f13945ae44da62a
>> commit: 99027ccd1ec1b31fc74d63df2f13945ae44da62a [4/4] arm: port KCOV to arm
>> config: arm-allmodconfig (attached as .config)
>> compiler: arm-linux-gnueabi-gcc (Debian 7.2.0-11) 7.2.0
>> reproduce:
>>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>>         chmod +x ~/bin/make.cross
>>         git checkout 99027ccd1ec1b31fc74d63df2f13945ae44da62a
>>         # save the attached .config to linux build tree
>>         make.cross ARCH=arm
>>
>> All errors (new ones prefixed by >>):
>>
>>    /tmp/ccMETRHQ.s: Assembler messages:
>> >> /tmp/ccMETRHQ.s:35: Error: .err encountered
>>    /tmp/ccMETRHQ.s:36: Error: .err encountered
>>    /tmp/ccMETRHQ.s:37: Error: .err encountered
>
> Huh, what is this supposed to mean?


I think that Arnd has fixed this with "ARM: disable KCOV for
trusted foundations code" now:
https://patchwork.kernel.org/patch/10434909/
The failure mode he referenced matches reported here.
