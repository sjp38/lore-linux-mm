Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9FD466B791F
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 10:12:41 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x85-v6so5941940pfe.13
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 07:12:41 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id a93-v6si5056093pla.277.2018.09.06.07.12.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 07:12:40 -0700 (PDT)
Subject: Re: [RFC][PATCH 2/5] [PATCH 2/5] proc: introduce
 /proc/PID/idle_bitmap
References: <20180901112818.126790961@intel.com>
 <20180901124811.530300789@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <71597e5c-8a7c-3a74-5b6d-6293f07f9a34@intel.com>
Date: Thu, 6 Sep 2018 07:12:39 -0700
MIME-Version: 1.0
In-Reply-To: <20180901124811.530300789@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Huang Ying <ying.huang@intel.com>, Brendan Gregg <bgregg@netflix.com>, Peng DongX <dongx.peng@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On 09/01/2018 04:28 AM, Fengguang Wu wrote:
> To walk 1TB memory of 4k active pages, it costs 2s vs 15s system
> time to scan the per-task/global idle bitmaps.

To me, that says this interface simply won't work on large systems.  2s
and 15s are both simply unacceptably long.

> OTOH, the per-task idle bitmap is not suitable in some situations:
> 
> - not accurate for shared pages
> - don't work with non-mapped file pages
> - don't perform well for sparse page tables (pointed out by Huang Ying)

OK, so we have a new ABI that doesn't work on large systems, consumes
lots of time and resources to query and isn't suitable in quite a few
situations.
