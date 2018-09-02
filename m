Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9193F6B6145
	for <linux-mm@kvack.org>; Sun,  2 Sep 2018 04:24:22 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id j15-v6so9348980pff.12
        for <linux-mm@kvack.org>; Sun, 02 Sep 2018 01:24:22 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id k23-v6si13451326pgl.633.2018.09.02.01.24.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Sep 2018 01:24:21 -0700 (PDT)
Date: Sun, 2 Sep 2018 16:24:01 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH 0/5] introduce /proc/PID/idle_bitmap
Message-ID: <20180902082401.jaz3dcumtxekwide@wfg-t540p.sh.intel.com>
References: <20180901112818.126790961@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20180901112818.126790961@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, kvm@vger.kernel.org, Peng DongX <dongx.peng@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Huang Ying <ying.huang@intel.com>, Brendan Gregg <bgregg@netflix.com>, LKML <linux-kernel@vger.kernel.org>

Here are the diffstat:

 arch/x86/kvm/Kconfig    |   11 +
 arch/x86/kvm/Makefile   |    4
 arch/x86/kvm/ept_idle.c |  329 ++++++++++++++++++++++++++++++++++++++
 arch/x86/kvm/ept_idle.h |   79 +++++++++
 fs/proc/base.c          |    2
 fs/proc/internal.h      |    1
 fs/proc/task_mmu.c      |   63 +++++++
 include/linux/sched.h   |   10 +
 virt/kvm/kvm_main.c     |    1
 9 files changed, 500 insertions(+)

Regards,
Fengguang
