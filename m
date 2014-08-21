Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 5B8E16B0035
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 12:57:38 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fa1so14722251pad.41
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 09:57:38 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id fn2si37171497pbc.168.2014.08.21.09.57.36
        for <linux-mm@kvack.org>;
        Thu, 21 Aug 2014 09:57:37 -0700 (PDT)
Message-ID: <1408640221.26863.29.camel@rzwisler-mobl1.amr.corp.intel.com>
Subject: Re: [RFC 6/9] SQUASHME: prd: Let each prd-device manage private
 memory region
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Date: Thu, 21 Aug 2014 10:57:01 -0600
In-Reply-To: <53EB5783.5020103@plexistor.com>
References: <53EB5536.8020702@gmail.com> <53EB5783.5020103@plexistor.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Sagi Manole <sagi@plexistor.com>, Yigal Korman <yigal@plexistor.com>

On Wed, 2014-08-13 at 15:18 +0300, Boaz Harrosh wrote:
> From: Boaz Harrosh <boaz@plexistor.com>
> 
> This patch removes any global memory information. And lets
> each prd-device manage it's own memory region.
> 
> prd_alloc() Now receives phys_addr and disk_size and will
> map that region, also prd_free will do the unmaping.
> 
> This is so we can support multiple discontinuous memory regions
> in the next patch
> 
> Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
> ---
>  drivers/block/prd.c | 125 ++++++++++++++++++++++++++++++++--------------------
>  1 file changed, 78 insertions(+), 47 deletions(-)

Looks great.

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
