Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B07E16B0008
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 14:36:58 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u8-v6so916854pfn.18
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 11:36:58 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id q28-v6si1469213pgm.362.2018.07.17.11.36.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 11:36:57 -0700 (PDT)
Subject: Re: [PATCH v2 7/7] swap, put_swap_page: Share more between
 huge/normal code path
References: <20180717005556.29758-1-ying.huang@intel.com>
 <20180717005556.29758-8-ying.huang@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <98288fec-1199-1b25-8c8c-18d60c33e596@linux.intel.com>
Date: Tue, 17 Jul 2018 11:36:54 -0700
MIME-Version: 1.0
In-Reply-To: <20180717005556.29758-8-ying.huang@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dan Williams <dan.j.williams@intel.com>

On 07/16/2018 05:55 PM, Huang, Ying wrote:
> 		text	   data	    bss	    dec	    hex	filename
> base:	       24215	   2028	    340	  26583	   67d7	mm/swapfile.o
> unified:       24577	   2028	    340	  26945	   6941	mm/swapfile.o

That's a bit more than I'd expect looking at the rest of the diff.  Make
me wonder if we missed an #ifdef somewhere or the compiler is getting
otherwise confused.

Might be worth a 10-minute look at the disassembly.
