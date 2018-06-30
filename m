Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E081A6B0003
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 14:07:24 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j7-v6so6227591pff.16
        for <linux-mm@kvack.org>; Sat, 30 Jun 2018 11:07:24 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g10-v6si10236893pgv.315.2018.06.30.11.07.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jun 2018 11:07:23 -0700 (PDT)
Date: Sat, 30 Jun 2018 11:07:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: /tmp/cctnQ1CM.s:35: Error: .err encountered
Message-Id: <20180630110720.c80f060abe6d163eef78e9a6@linux-foundation.org>
In-Reply-To: <CACT4Y+b+7T3M=5EbHSpJmMAkRQnXih2+JZqeAvxht2zzKyjD2A@mail.gmail.com>
References: <201806301538.bewm1wka%fengguang.wu@intel.com>
	<CACT4Y+b+7T3M=5EbHSpJmMAkRQnXih2+JZqeAvxht2zzKyjD2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Sat, 30 Jun 2018 12:27:09 +0200 Dmitry Vyukov <dvyukov@google.com> wrote:

> > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> > head:   1904148a361a07fb2d7cba1261d1d2c2f33c8d2e
> > commit: 758517202bd2e427664857c9f2aa59da36848aca arm: port KCOV to arm
> > date:   2 weeks ago
> > config: arm-allmodconfig (attached as .config)
> > compiler: arm-linux-gnueabi-gcc (Debian 7.2.0-11) 7.2.0
> > reproduce:
> >         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
> >         chmod +x ~/bin/make.cross
> >         git checkout 758517202bd2e427664857c9f2aa59da36848aca
> >         # save the attached .config to linux build tree
> >         GCC_VERSION=7.2.0 make.cross ARCH=arm
> >
> > All errors (new ones prefixed by >>):
> >
> >    /tmp/cctnQ1CM.s: Assembler messages:
> >>> /tmp/cctnQ1CM.s:35: Error: .err encountered
> >    /tmp/cctnQ1CM.s:36: Error: .err encountered
> >    /tmp/cctnQ1CM.s:37: Error: .err encountered
> 
> Hi kbuild test robot,
> 
> The fix was mailed more than a month ago, but still not merged into
> the tree. That's linux...

That was a rather unhelpful email.

I've just scanned all your lkml emails since the start of May and
cannot find anything which looks like a fix for this issue.

Please resend.   About three weks ago :(
