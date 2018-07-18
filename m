Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 57B7A6B0008
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 11:13:38 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g20-v6so2483165pfi.2
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 08:13:38 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id t128-v6si3291800pgt.598.2018.07.18.08.13.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 08:13:37 -0700 (PDT)
Subject: Re: [PATCH v2 7/7] swap, put_swap_page: Share more between
 huge/normal code path
References: <20180717005556.29758-1-ying.huang@intel.com>
 <20180717005556.29758-8-ying.huang@intel.com>
 <98288fec-1199-1b25-8c8c-18d60c33e596@linux.intel.com>
 <87k1ptgskf.fsf@yhuang-dev.intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <b8a9d250-81b2-0c0b-e1c6-57dbfa11be82@linux.intel.com>
Date: Wed, 18 Jul 2018 08:13:34 -0700
MIME-Version: 1.0
In-Reply-To: <87k1ptgskf.fsf@yhuang-dev.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dan Williams <dan.j.williams@intel.com>

On 07/17/2018 07:56 PM, Huang, Ying wrote:
> -.orc_unwind_ip                        1380      0
> -.orc_unwind                           2070      0
> -Total                                26810
> +.orc_unwind_ip                        1480      0
> +.orc_unwind                           2220      0
> +Total                                27172
> 
> The total difference is same: 27172 - 26810 = 362 = 24577 - 24215.
> 
> The text section difference is small: 17927 - 17815 = 112.  The
> additional size change comes from unwinder information: (1480 + 2220) -
> (1380 + 2070) = 250.  If the frame pointer unwinder is chosen, this cost
> nothing, but if the ORC unwinder is chosen, this is the real difference.
> 
> For 112 text section difference, use 'objdump -t' to get symbol size and
> compare,

Cool, thanks for doing this!

I think what you've done here is great for readability and the binary
size increase is well worth the modest size increase.
