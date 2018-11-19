Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id E3ADF6B1880
	for <linux-mm@kvack.org>; Sun, 18 Nov 2018 23:14:05 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id e10so20673014oth.21
        for <linux-mm@kvack.org>; Sun, 18 Nov 2018 20:14:05 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e99si17114333ote.64.2018.11.18.20.14.04
        for <linux-mm@kvack.org>;
        Sun, 18 Nov 2018 20:14:04 -0800 (PST)
Subject: Re: [PATCH 4/7] node: Add memory caching attributes
References: <20181114224921.12123-2-keith.busch@intel.com>
 <20181114224921.12123-5-keith.busch@intel.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <91698cef-cdcd-5143-884f-3da5536e156f@arm.com>
Date: Mon, 19 Nov 2018 09:44:00 +0530
MIME-Version: 1.0
In-Reply-To: <20181114224921.12123-5-keith.busch@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>



On 11/15/2018 04:19 AM, Keith Busch wrote:
> System memory may have side caches to help improve access speed. While
> the system provided cache is transparent to the software accessing
> these memory ranges, applications can optimize their own access based
> on cache attributes.

Cache is not a separate memory attribute. It impacts how the real attributes
like bandwidth, latency e.g which are already captured in the previous patch.
What is the purpose of adding this as a separate attribute ? Can you explain
how this is going to help the user space apart from the hints it has already
received with bandwidth, latency etc properties.

> 
> In preparation for such systems, provide a new API for the kernel to
> register these memory side caches under the memory node that provides it.

Under target memory node interface /sys/devices/system/node/nodeY/target* ?

> 
> The kernel's sysfs representation is modeled from the cpu cacheinfo
> attributes, as seen from /sys/devices/system/cpu/cpuX/cache/. Unlike CPU
> cacheinfo, though, a higher node's memory cache level is nearer to the
> CPU, while lower levels are closer to the backing memory. Also unlike
> CPU cache, the system handles flushing any dirty cached memory to the
> last level the memory on a power failure if the range is persistent.

Lets assume that a CPU has got four levels of caches L1, L2, L3, L4 before
reaching memory. L4 is the backing cache for the memory and L1-L3 is from
CPU till the system bus. Hence some of them will be represented as CPU
caches and some of them will be represented as memory caches ?

/sys/devices/system/cpu/cpuX/cache/ --> L1, L2, L3
/sys/devices/system/node/nodeY/target --> L4 

L4 will be listed even if the node is memory only ?
