Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D18386B0033
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 21:20:11 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v78so12956280pgb.18
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 18:20:11 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id h13si4225580pgq.28.2017.10.23.18.20.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Oct 2017 18:20:10 -0700 (PDT)
Date: Mon, 23 Oct 2017 18:06:33 -0700
From: Sharath Kumar Bhat <sharath.k.bhat@linux.intel.com>
Subject: Re: [PATCH] mm: fix movable_node kernel command-line
Message-ID: <20171024010633.GA2723@linux.intel.com>
Reply-To: sharath.k.bhat@linux.intel.com
References: <20171023171435.GA12025@linux.intel.com>
 <20171023172008.kr6dzpe63nfpgps7@dhcp22.suse.cz>
 <20171023173544.GA12198@linux.intel.com>
 <20171023174905.ap4uz6puggeqnz3s@dhcp22.suse.cz>
 <20171023184852.GB12198@linux.intel.com>
 <20171023190459.odyu26rqhuja4trj@dhcp22.suse.cz>
 <20171023192524.GC12198@linux.intel.com>
 <20171023193536.c7yptc4tpesa4ffl@dhcp22.suse.cz>
 <20171023195637.GE12198@linux.intel.com>
 <0ed8144f-4447-e2de-47f7-ea1fc16f0b25@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0ed8144f-4447-e2de-47f7-ea1fc16f0b25@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: sharath.k.bhat@linux.intel.com, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, akpm@linux-foundation.org

On Mon, Oct 23, 2017 at 02:52:04PM -0700, Dave Hansen wrote:
> On 10/23/2017 12:56 PM, Sharath Kumar Bhat wrote:
> >> I am sorry for being dense here but why cannot you mark that memory
> >> hotplugable? I assume you are under the control to set attributes of the
> >> memory to the guest.
> > When I said two OS's I meant multi-kernel environment sharing the same
> > hardware and not VMs. So we do not have the control to mark the memory
> > hotpluggable as done by BIOS through SRAT.
> 
> If you are going as far as to pass in custom kernel command-line
> arguments, there's a bunch of other fun stuff you can do.  ACPI table
> overrides come to mind.
> 
> > This facility can be used by platform/BIOS vendors to provide a Linux
> > compatible environment without modifying the underlying platform firmware.
> 
> https://www.kernel.org/doc/Documentation/acpi/initrd_table_override.txt

I think ACPI table override won't be a generic solution to this problem and
instead would be a platform/architecture dependent solution which may not
be flexible for the users on different architectures. And moreover
'movable_node' is implemented with an assumption to provide the entire
hotpluggable memory as movable zone. This ACPI override would be against
that assumption. Also ACPI override would introduce additional topology
changes. Again this would have to change every time the total movable
memory requirement changes and the whole system and apps have to be
re-tuned (for job launch ex: numactl etc) to comphrehend this change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
