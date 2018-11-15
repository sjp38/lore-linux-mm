Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id EE5176B000E
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 19:40:52 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id t5-v6so13294789plo.2
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 16:40:52 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id g67-v6si18410326plb.163.2018.11.14.16.40.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 16:40:51 -0800 (PST)
Subject: Re: [PATCH 4/7] node: Add memory caching attributes
References: <20181114224921.12123-2-keith.busch@intel.com>
 <20181114224921.12123-5-keith.busch@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <a000e296-7d7f-6a98-3869-3b476101749e@intel.com>
Date: Wed, 14 Nov 2018 16:40:51 -0800
MIME-Version: 1.0
In-Reply-To: <20181114224921.12123-5-keith.busch@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dan Williams <dan.j.williams@intel.com>

On 11/14/18 2:49 PM, Keith Busch wrote:
> System memory may have side caches to help improve access speed. While
> the system provided cache is transparent to the software accessing
> these memory ranges, applications can optimize their own access based
> on cache attributes.
> 
> In preparation for such systems, provide a new API for the kernel to
> register these memory side caches under the memory node that provides it.
> 
> The kernel's sysfs representation is modeled from the cpu cacheinfo
> attributes, as seen from /sys/devices/system/cpu/cpuX/cache/. Unlike CPU
> cacheinfo, though, a higher node's memory cache level is nearer to the
> CPU, while lower levels are closer to the backing memory. Also unlike
> CPU cache, the system handles flushing any dirty cached memory to the
> last level the memory on a power failure if the range is persistent.
> 
> The exported attributes are the cache size, the line size, associativity,
> and write back policy.

Could you also include an example of the layout?
