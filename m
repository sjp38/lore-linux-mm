Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 642216B6854
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 04:22:27 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id t1so2510951wmt.5
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 01:22:27 -0800 (PST)
Received: from mail2-relais-roc.national.inria.fr (mail2-relais-roc.national.inria.fr. [192.134.164.83])
        by mx.google.com with ESMTPS id w8si10319886wrp.196.2018.12.03.01.22.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 01:22:25 -0800 (PST)
Subject: Re: [PATCH 0/9] Allow persistent memory to be used like normal RAM
References: <20181022201317.8558C1D8@viggo.jf.intel.com>
From: Brice Goglin <brice.goglin@gmail.com>
Message-ID: <ffeb6225-6d5c-099e-3158-4711c879ec23@gmail.com>
Date: Mon, 3 Dec 2018 10:22:24 +0100
MIME-Version: 1.0
In-Reply-To: <20181022201317.8558C1D8@viggo.jf.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org
Cc: dan.j.williams@intel.com, dave.jiang@intel.com, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, akpm@linux-foundation.org, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, ying.huang@intel.com, fengguang.wu@intel.com

Le 22/10/2018 à 22:13, Dave Hansen a écrit :
> Persistent memory is cool.  But, currently, you have to rewrite
> your applications to use it.  Wouldn't it be cool if you could
> just have it show up in your system like normal RAM and get to
> it like a slow blob of memory?  Well... have I got the patch
> series for you!
>
> This series adds a new "driver" to which pmem devices can be
> attached.  Once attached, the memory "owned" by the device is
> hot-added to the kernel and managed like any other memory.  On
> systems with an HMAT (a new ACPI table), each socket (roughly)
> will have a separate NUMA node for its persistent memory so
> this newly-added memory can be selected by its unique NUMA
> node.


Hello Dave

What happens on systems without an HMAT? Does this new memory get merged
into existing NUMA nodes?

Also, do you plan to have a way for applications to find out which NUMA
nodes are "real DRAM" while others are "pmem-backed"? (something like a
new attribute in /sys/devices/system/node/nodeX/) Or should we use HMAT
performance attributes for this?

Brice
