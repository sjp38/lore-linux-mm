Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A41986B0269
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 09:39:55 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id m18-v6so5746942eds.0
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 06:39:55 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y13-v6si3255751edi.209.2018.07.02.06.39.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 06:39:54 -0700 (PDT)
Date: Mon, 2 Jul 2018 15:39:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v3 PATCH 0/5] mm: zap pages with read mmap_sem in munmap
 for large mapping
Message-ID: <20180702133953.GV19043@dhcp22.suse.cz>
References: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, tglx@linutronix.de, hpa@zytor.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Sat 30-06-18 06:39:40, Yang Shi wrote:
> 
> Background:
> Recently, when we ran some vm scalability tests on machines with large memory,
> we ran into a couple of mmap_sem scalability issues when unmapping large memory
> space, please refer to https://lkml.org/lkml/2017/12/14/733 and
> https://lkml.org/lkml/2018/2/20/576.
> 
> 
> History:
> Then akpm suggested to unmap large mapping section by section and drop mmap_sem
> at a time to mitigate it (see https://lkml.org/lkml/2018/3/6/784).
> 
> V1 patch series was submitted to the mailing list per Andrewa??s suggestion
> (see https://lkml.org/lkml/2018/3/20/786). Then I received a lot great feedback
> and suggestions.
> 
> Then this topic was discussed on LSFMM summit 2018. In the summit, Michal Hock
> suggested (also in the v1 patches review) to try "two phases" approach. Zapping
> pages with read mmap_sem, then doing via cleanup with write mmap_sem (for
> discussion detail, see https://lwn.net/Articles/753269/)

The cover letter should really describe your approach to the problem.
But there is none here.
-- 
Michal Hocko
SUSE Labs
