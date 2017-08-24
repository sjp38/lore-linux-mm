Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E6A9B440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 12:08:38 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id n185so3290035pga.11
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 09:08:38 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id p28si2990310pgc.575.2017.08.24.09.08.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 09:08:37 -0700 (PDT)
Subject: Re: [RESEND PATCH 0/3] mm: Add cache coloring mechanism
References: <20170823100205.17311-1-lukasz.daniluk@intel.com>
 <f95eacd5-0a91-24a0-7722-b63f3c196552@suse.cz>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <82cc1886-6c24-4e6e-7269-4d150e9f39eb@intel.com>
Date: Thu, 24 Aug 2017 09:08:32 -0700
MIME-Version: 1.0
In-Reply-To: <f95eacd5-0a91-24a0-7722-b63f3c196552@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, =?UTF-8?Q?=c5=81ukasz_Daniluk?= <lukasz.daniluk@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: lukasz.anaczkowski@intel.com

On 08/24/2017 05:47 AM, Vlastimil Babka wrote:
> So the obvious question, what about THPs? Their size should be enough to
> contain all the colors with current caches, no? Even on KNL I didn't
> find more than "32x 1 MB 16-way L2 caches". This is in addition to the
> improved TLB performance, which you want to get as well for such workloads?

The cache in this case is "MCDRAM" which is 16GB in size.  It can be
used as normal RAM or a cache.  This patch deals with when "MCDRAM" is
in its cache mode.

It's described in the "Memory Modes" slide here:

> http://www.nersc.gov/users/computational-systems/cori/configuration/knl-processor-modes/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
