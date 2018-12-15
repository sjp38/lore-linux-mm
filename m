Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E72668E0001
	for <linux-mm@kvack.org>; Sat, 15 Dec 2018 14:23:58 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id n17so7351922pfk.23
        for <linux-mm@kvack.org>; Sat, 15 Dec 2018 11:23:58 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w24si6985078pgj.582.2018.12.15.11.23.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Dec 2018 11:23:57 -0800 (PST)
Date: Sat, 15 Dec 2018 11:23:46 -0800
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [mmotm:master 291/302] fs/buffer.c:2400:37: error: expected
 statement before ')' token
Message-ID: <20181215192346.z6hitrgdsfng76ik@linux-r8p5>
References: <201812151636.P1KU0v8x%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <201812151636.P1KU0v8x%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Sat, 15 Dec 2018, kbuild test robot wrote:

>tree:   git://git.cmpxchg.org/linux-mmotm.git master
>head:   6d5b029d523e959579667282e713106a29c193d2
>commit: dc946e7f683be2016c12d8d75e6dd3a28a0d3adb [291/302] fs/: remove caller signal_pending branch predictions
>config: x86_64-rhel-7.2-clear (attached as .config)
>compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
>reproduce:
>        git checkout dc946e7f683be2016c12d8d75e6dd3a28a0d3adb
>        # save the attached .config to linux build tree
>        make ARCH=x86_64
>
>Note: the mmotm/master HEAD 6d5b029d523e959579667282e713106a29c193d2 builds fine.
>      It only hurts bisectibility.
>
>All error/warnings (new ones prefixed by >>):
>
>   fs/buffer.c: In function 'cont_expand_zero':
>>> fs/buffer.c:2400:37: error: expected statement before ')' token
>      if (fatal_signal_pending(current))) {

This was fixed by Andrew a while ago:

https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/commit/?id=2a95392eaba5fee94cc22ebf2391a507f7a63636

Thanks,
Davidlohr
