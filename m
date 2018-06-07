Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 085DF6B0003
	for <linux-mm@kvack.org>; Wed,  6 Jun 2018 22:02:54 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id o19-v6so2882875pgn.14
        for <linux-mm@kvack.org>; Wed, 06 Jun 2018 19:02:53 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id i11-v6si24179691pgc.350.2018.06.06.19.02.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jun 2018 19:02:50 -0700 (PDT)
Message-ID: <1528336942.3147.52.camel@intel.com>
Subject: Re: FW: [kbuild-all] [linux-next:master 5885/8111]
 /tmp/cc3gKKeM.s:35: Error: .err encountered
From: Chen Rong <rongx.a.chen@intel.com>
Date: Thu, 07 Jun 2018 10:02:22 +0800
In-Reply-To: <831EE4E5E37DCC428EB295A351E662494CB9C137@shsmsx102.ccr.corp.intel.com>
References: <201805210314.e6bdStHL%fengguang.wu@intel.com>
	 <CACT4Y+bR+ywj_OtGDYiCp+PZ4MfdqfrXg5XQwN36uRnNCEHEZg@mail.gmail.com>
	 <831EE4E5E37DCC428EB295A351E662494CB5166D@shsmsx102.ccr.corp.intel.com>
	 <831EE4E5E37DCC428EB295A351E662494CB9C137@shsmsx102.ccr.corp.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dvyukov@google.com
Cc: lkp@intel.com, linux-mm@kvack.org, akpm@linux-foundation.org, kbuild-all@01.org

Hi Dmitry,

We have updated the make.cross. you could get the new one from https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross
and run the command "GCC_VERSION=7.2.0 make.cross ARCH=arm"

Thanks!

> -----Original Message-----
> From: kbuild-all [mailto:kbuild-all-bounces@lists.01.org] On Behalf Of Li, Philip
> Sent: Saturday, May 26, 2018 10:37 PM
> To: Dmitry Vyukov <dvyukov@google.com>; lkp <lkp@intel.com>
> Cc: Linux Memory Management List <linux-mm@kvack.org>; Andrew Morton <akpm@linux-foundation.org>; kbuild-all@01.org
> Subject: Re: [kbuild-all] [linux-next:master 5885/8111] /tmp/cc3gKKeM.s:35: Error: .err encountered
> 
> > Subject: Re: [kbuild-all] [linux-next:master 5885/8111] /tmp/cc3gKKeM.s:35:
> > Error: .err encountered
> > 
> > On Sun, May 20, 2018 at 9:15 PM, kbuild test robot <lkp@intel.com> wrote:
> > > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> > > head:   fbbe3b8c2c9c5f84caf668703c26154cb4fbb9d1
> > > commit: 3b67022379d3d0c6a5cc5152f6b46eeea635a194 [5885/8111] arm: port
> > 
> > KCOV to arm
> > > config: arm-allmodconfig (attached as .config)
> > > compiler: arm-linux-gnueabi-gcc (Debian 7.2.0-11) 7.2.0
> > > reproduce:
> > >         wget https://raw.githubusercontent.com/intel/lkp-
> > 
> > tests/master/sbin/make.cross -O ~/bin/make.cross
> > >         chmod +x ~/bin/make.cross
> > >         git checkout 3b67022379d3d0c6a5cc5152f6b46eeea635a194
> > >         # save the attached .config to linux build tree
> > >         make.cross ARCH=arm
> > > 
> > > All errors (new ones prefixed by >>):
> > > 
> > >    /tmp/cc3gKKeM.s: Assembler messages:
> > > > > /tmp/cc3gKKeM.s:35: Error: .err encountered
> > > 
> > >    /tmp/cc3gKKeM.s:36: Error: .err encountered
> > >    /tmp/cc3gKKeM.s:37: Error: .err encountered
> > 
> > I've tried to reproduce this following the instructions, but I failed,
> 
> thanks for input, we will follow up this to see whether there's issue
> in bot side.
> 
> > build succeeds for me:
> > https://www.spinics.net/lists/linux-mm/msg152336.html
> > _______________________________________________
> > kbuild-all mailing list
> > kbuild-all@lists.01.org
> > https://lists.01.org/mailman/listinfo/kbuild-all
> 
> _______________________________________________
> kbuild-all mailing list
> kbuild-all@lists.01.org
> https://lists.01.org/mailman/listinfo/kbuild-all
