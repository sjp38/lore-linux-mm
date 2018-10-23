Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1BE376B0007
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 14:16:54 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id o3-v6so1071161pll.7
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 11:16:54 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id n11-v6si1844428plk.333.2018.10.23.11.16.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 11:16:52 -0700 (PDT)
Subject: Re: [PATCH 0/9] Allow persistent memory to be used like normal RAM
References: <20181022201317.8558C1D8@viggo.jf.intel.com>
 <CAPcyv4hxs-GnmwQU1wPZyg5aydCY5K09-YpSrrLpvU1v_8dbBw@mail.gmail.com>
 <AT5PR8401MB11694012893ED2121D7A345EABF50@AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <2677a7f9-5dc8-7590-2b8b-a67da1cb6b92@intel.com>
Date: Tue, 23 Oct 2018 11:16:52 -0700
MIME-Version: 1.0
In-Reply-To: <AT5PR8401MB11694012893ED2121D7A345EABF50@AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>, 'Dan Williams' <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: Tom Lendacky <thomas.lendacky@amd.com>, "Hocko, Michal" <MHocko@suse.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, "Huang, Ying" <ying.huang@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "zwisler@kernel.org" <zwisler@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>

>> This series adds a new "driver" to which pmem devices can be
>> attached.  Once attached, the memory "owned" by the device is
>> hot-added to the kernel and managed like any other memory.  On
> 
> Would this memory be considered volatile (with the driver initializing
> it to zeros), or persistent (contents are presented unchanged,
> applications may guarantee persistence by using cache flush
> instructions, fence instructions, and writing to flush hint addresses
> per the persistent memory programming model)?

Volatile.

>> I expect udev can automate this by setting up a rule to watch for
>> device-dax instances by UUID and call a script to do the detach /
>> reattach dance.
> 
> Where would that rule be stored? Storing it on another device
> is problematic. If that rule is lost, it could confuse other
> drivers trying to grab device DAX devices for use as persistent
> memory.

Well, we do lots of things like stable device naming from udev scripts.
 We depend on them not being lost.  At least this "fails safe" so we'll
default to persistence instead of defaulting to "eat your data".
