Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9581E6B0038
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 16:06:33 -0400 (EDT)
Received: by mail-we0-f178.google.com with SMTP id w61so8076227wes.23
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 13:06:33 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id ef9si30233292wjd.148.2014.07.21.13.06.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jul 2014 13:06:32 -0700 (PDT)
Date: Mon, 21 Jul 2014 22:06:25 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC Patch V1 00/30] Enable memoryless node on x86 platforms
Message-ID: <20140721200625.GR3935@laptop>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
 <20140721172331.GB4156@linux.vnet.ibm.com>
 <CA+8MBbK+ZdisT_yXh_jkWSd4hWEMisG614s4s0EyNV3j-7YOow@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+8MBbK+ZdisT_yXh_jkWSd4hWEMisG614s4s0EyNV3j-7YOow@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, Jiang Liu <jiang.liu@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-hotplug@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Jul 21, 2014 at 10:41:59AM -0700, Tony Luck wrote:
> On Mon, Jul 21, 2014 at 10:23 AM, Nishanth Aravamudan
> <nacc@linux.vnet.ibm.com> wrote:
> > It seems like the issue is the order of onlining of resources on a
> > specific x86 platform?
> 
> Yes. When we online a node the BIOS hits us with some ACPI hotplug events:
> 
> First: Here are some new cpus
> Next: Here is some new memory
> Last; Here are some new I/O things (PCIe root ports, PCIe devices,
> IOAPICs, IOMMUs, ...)
> 
> So there is a period where the node is memoryless - although that will generally
> be resolved when the memory hot plug event arrives ... that isn't guaranteed to
> occur (there might not be any memory on the node, or what memory there is
> may have failed self-test and been disabled).

Right, but we could 'easily' capture that in arch code and make it look
like it was done in a 'sane' order. No need to wreck the rest of the
kernel to support this particular BIOS fuckup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
