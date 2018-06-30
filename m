Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 317A96B0008
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 06:27:32 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id q15-v6so100309pgc.23
        for <linux-mm@kvack.org>; Sat, 30 Jun 2018 03:27:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r9-v6sor3664421plo.33.2018.06.30.03.27.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 30 Jun 2018 03:27:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201806301538.bewm1wka%fengguang.wu@intel.com>
References: <201806301538.bewm1wka%fengguang.wu@intel.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sat, 30 Jun 2018 12:27:09 +0200
Message-ID: <CACT4Y+b+7T3M=5EbHSpJmMAkRQnXih2+JZqeAvxht2zzKyjD2A@mail.gmail.com>
Subject: Re: /tmp/cctnQ1CM.s:35: Error: .err encountered
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Sat, Jun 30, 2018 at 9:15 AM, kbuild test robot <lkp@intel.com> wrote:
> Hi Dmitry,
>
> FYI, the error/warning still remains.
>
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   1904148a361a07fb2d7cba1261d1d2c2f33c8d2e
> commit: 758517202bd2e427664857c9f2aa59da36848aca arm: port KCOV to arm
> date:   2 weeks ago
> config: arm-allmodconfig (attached as .config)
> compiler: arm-linux-gnueabi-gcc (Debian 7.2.0-11) 7.2.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 758517202bd2e427664857c9f2aa59da36848aca
>         # save the attached .config to linux build tree
>         GCC_VERSION=7.2.0 make.cross ARCH=arm
>
> All errors (new ones prefixed by >>):
>
>    /tmp/cctnQ1CM.s: Assembler messages:
>>> /tmp/cctnQ1CM.s:35: Error: .err encountered
>    /tmp/cctnQ1CM.s:36: Error: .err encountered
>    /tmp/cctnQ1CM.s:37: Error: .err encountered

Hi kbuild test robot,

The fix was mailed more than a month ago, but still not merged into
the tree. That's linux...
