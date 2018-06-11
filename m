Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A7EC36B0005
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 03:09:18 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id c9-v6so12599786wrm.14
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 00:09:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y59-v6si1559864ede.189.2018.06.11.00.09.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Jun 2018 00:09:17 -0700 (PDT)
Date: Mon, 11 Jun 2018 09:09:16 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [memcg:akpm/kcov 4/4] /tmp/ccMETRHQ.s:35: Error: .err encountered
Message-ID: <20180611070916.GB13364@dhcp22.suse.cz>
References: <201806111409.N4l80RQU%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201806111409.N4l80RQU%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, kbuild-all@01.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Mon 11-06-18 14:57:10, kbuild test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git akpm/kcov
> head:   99027ccd1ec1b31fc74d63df2f13945ae44da62a
> commit: 99027ccd1ec1b31fc74d63df2f13945ae44da62a [4/4] arm: port KCOV to arm
> config: arm-allmodconfig (attached as .config)
> compiler: arm-linux-gnueabi-gcc (Debian 7.2.0-11) 7.2.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 99027ccd1ec1b31fc74d63df2f13945ae44da62a
>         # save the attached .config to linux build tree
>         make.cross ARCH=arm 
> 
> All errors (new ones prefixed by >>):
> 
>    /tmp/ccMETRHQ.s: Assembler messages:
> >> /tmp/ccMETRHQ.s:35: Error: .err encountered
>    /tmp/ccMETRHQ.s:36: Error: .err encountered
>    /tmp/ccMETRHQ.s:37: Error: .err encountered

Huh, what is this supposed to mean?

-- 
Michal Hocko
SUSE Labs
