Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 087CB6B6A43
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 11:56:24 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id s22so7152343pgv.8
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 08:56:24 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 11si12741464pgs.126.2018.12.03.08.56.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 08:56:22 -0800 (PST)
Subject: Re: [PATCH 0/9] Allow persistent memory to be used like normal RAM
References: <20181022201317.8558C1D8@viggo.jf.intel.com>
 <ffeb6225-6d5c-099e-3158-4711c879ec23@gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <48d78370-438d-65fa-370c-4cf61a27ed3d@intel.com>
Date: Mon, 3 Dec 2018 08:56:22 -0800
MIME-Version: 1.0
In-Reply-To: <ffeb6225-6d5c-099e-3158-4711c879ec23@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brice Goglin <brice.goglin@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org
Cc: dan.j.williams@intel.com, dave.jiang@intel.com, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, akpm@linux-foundation.org, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, ying.huang@intel.com, fengguang.wu@intel.com, Keith Busch <keith.busch@intel.com>

On 12/3/18 1:22 AM, Brice Goglin wrote:
> Le 22/10/2018 à 22:13, Dave Hansen a écrit :
> What happens on systems without an HMAT? Does this new memory get merged
> into existing NUMA nodes?

It gets merged into the persistent memory device's node, as told by the
firmware.  Intel's persistent memory should always be in its own node,
separate from DRAM.

> Also, do you plan to have a way for applications to find out which NUMA
> nodes are "real DRAM" while others are "pmem-backed"? (something like a
> new attribute in /sys/devices/system/node/nodeX/) Or should we use HMAT
> performance attributes for this?

The best way is to use the sysfs-generic interfaces to the HMAT that
Keith Busch is pushing.  In the end, we really think folks will only
care about the memory's performance properties rather than whether it's
*actually* persistent memory or not.
