Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4F0C96B0033
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 17:52:07 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 76so17078695pfr.3
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 14:52:07 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id x1si3187014plb.289.2017.10.23.14.52.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Oct 2017 14:52:06 -0700 (PDT)
Subject: Re: [PATCH] mm: fix movable_node kernel command-line
References: <20171023160314.GA11853@linux.intel.com>
 <20171023161554.zltjcls34kr4234m@dhcp22.suse.cz>
 <20171023171435.GA12025@linux.intel.com>
 <20171023172008.kr6dzpe63nfpgps7@dhcp22.suse.cz>
 <20171023173544.GA12198@linux.intel.com>
 <20171023174905.ap4uz6puggeqnz3s@dhcp22.suse.cz>
 <20171023184852.GB12198@linux.intel.com>
 <20171023190459.odyu26rqhuja4trj@dhcp22.suse.cz>
 <20171023192524.GC12198@linux.intel.com>
 <20171023193536.c7yptc4tpesa4ffl@dhcp22.suse.cz>
 <20171023195637.GE12198@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <0ed8144f-4447-e2de-47f7-ea1fc16f0b25@intel.com>
Date: Mon, 23 Oct 2017 14:52:04 -0700
MIME-Version: 1.0
In-Reply-To: <20171023195637.GE12198@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sharath.k.bhat@linux.intel.com, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On 10/23/2017 12:56 PM, Sharath Kumar Bhat wrote:
>> I am sorry for being dense here but why cannot you mark that memory
>> hotplugable? I assume you are under the control to set attributes of the
>> memory to the guest.
> When I said two OS's I meant multi-kernel environment sharing the same
> hardware and not VMs. So we do not have the control to mark the memory
> hotpluggable as done by BIOS through SRAT.

If you are going as far as to pass in custom kernel command-line
arguments, there's a bunch of other fun stuff you can do.  ACPI table
overrides come to mind.

> This facility can be used by platform/BIOS vendors to provide a Linux
> compatible environment without modifying the underlying platform firmware.

https://www.kernel.org/doc/Documentation/acpi/initrd_table_override.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
