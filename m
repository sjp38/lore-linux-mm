Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 555386B0006
	for <linux-mm@kvack.org>; Sun, 10 Jun 2018 20:02:04 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id d10-v6so5796622pgv.8
        for <linux-mm@kvack.org>; Sun, 10 Jun 2018 17:02:04 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x4-v6si11354618pgv.592.2018.06.10.17.02.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 10 Jun 2018 17:02:02 -0700 (PDT)
Subject: Re: [mmotm:master 192/212] include/uapi/asm-generic/int-ll64.h:20:1:
 error: expected '=', ',', ';', 'asm' or '__attribute__' before 'typedef'
References: <201806081045.eZrs5GGH%fengguang.wu@intel.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <533c0099-d2be-8fea-fe2f-1453ea049c33@infradead.org>
Date: Sun, 10 Jun 2018 17:01:48 -0700
MIME-Version: 1.0
In-Reply-To: <201806081045.eZrs5GGH%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>, Souptick Joarder <jrdr.linux@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>

On 06/07/2018 07:06 PM, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   7393732bae530daa27567988b91d16ecfeef6c62
> commit: b1a8bfbadbcb79644ccdd5f9cd370caa63cb1fa7 [192/212] linux-next-git-rejects
> config: i386-randconfig-s0-201822-CONFIG_DEBUG_INFO_REDUCED (attached as .config)
> compiler: gcc-6 (Debian 6.4.0-9) 6.4.0 20171026
> reproduce:
>         git checkout b1a8bfbadbcb79644ccdd5f9cd370caa63cb1fa7
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> All errors (new ones prefixed by >>):
> 
>    In file included from include/asm-generic/int-ll64.h:11:0,
>                     from include/uapi/asm-generic/types.h:7,
>                     from arch/x86/include/uapi/asm/types.h:5,
>                     from include/uapi/linux/types.h:5,
>                     from include/linux/types.h:6,
>                     from net/ipv4/ipconfig.c:36:
>>> include/uapi/asm-generic/int-ll64.h:20:1: error: expected '=', ',', ';', 'asm' or '__attribute__' before 'typedef'
>     typedef __signed__ char __s8;
>     ^~~~~~~

The problem here was that net/ipv4/ipconfig.c begins like this:

q// SPDX-License-Identifier: GPL-2.0

Did anyone fix that?


-- 
~Randy
