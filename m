Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 096B66B0316
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 07:06:29 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id o42so6054855edc.13
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 04:06:28 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t25-v6si1034109ejs.71.2018.11.06.04.06.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 04:06:27 -0800 (PST)
Subject: Re: [PATCH v3 2/2] mm/page_alloc: use a single function to free page
References: <20181105085820.6341-1-aaron.lu@intel.com>
 <20181105085820.6341-2-aaron.lu@intel.com> <20181106053037.GD6203@intel.com>
 <20181106113149.GC24198@intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <806ba56d-3213-bd9a-b52e-b54be19885d7@suse.cz>
Date: Tue, 6 Nov 2018 13:06:24 +0100
MIME-Version: 1.0
In-Reply-To: <20181106113149.GC24198@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, Yoel Caspersen <yoel@kviknet.dk>, Mel Gorman <mgorman@techsingularity.net>, Saeed Mahameed <saeedm@mellanox.com>, Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>

On 11/6/18 12:31 PM, Aaron Lu wrote:
> We have multiple places of freeing a page, most of them doing similar
> things and a common function can be used to reduce code duplicate.
> 
> It also avoids bug fixed in one function but left in another.
> 
> Signed-off-by: Aaron Lu <aaron.lu@intel.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!

> ---
> v3: Vlastimil mentioned the possible performance loss by using
>     page_ref_sub_and_test(page, 1) for put_page_testzero(page), since
>     we aren't sure so be safe by keeping page ref decreasing code as
>     is, only move freeing page part to a common function.
