Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 491BA6B0069
	for <linux-mm@kvack.org>; Thu, 30 Aug 2012 12:01:38 -0400 (EDT)
Message-ID: <503F8ECA.5090306@redhat.com>
Date: Thu, 30 Aug 2012 12:03:22 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch v3]swap: add a simple random read swapin detection
References: <20120827040037.GA8062@kernel.org> <503B8997.4040604@openvz.org> <20120830103612.GA12292@kernel.org>
In-Reply-To: <20120830103612.GA12292@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, akpm@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>, "minchan@kernel.org" <minchan@kernel.org>

On 08/30/2012 06:36 AM, Shaohua Li wrote:

> Interesting is the randwrite harddisk test is improved too. This might be
> because swapin readahead need allocate extra memory, which further tights
> memory pressure, so more swapout/swapin.
>
> This patch depends on readahead-fault-retry-breaks-mmap-file-read-random-detection.patch
>
> V2->V3:
> move swapra_miss to 'struct anon_vma' as suggested by Konstantin.
>
> V1->V2:
> 1. Move the swap readahead accounting to separate functions as suggested by Riel.
> 2. Enable the logic only with CONFIG_SWAP enabled as suggested by Minchan.
>
> Signed-off-by: Shaohua Li <shli@fusionio.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
