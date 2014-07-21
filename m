Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f181.google.com (mail-vc0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id C52E36B007B
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 13:42:00 -0400 (EDT)
Received: by mail-vc0-f181.google.com with SMTP id lf12so12717864vcb.40
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 10:42:00 -0700 (PDT)
Received: from mail-vc0-x22d.google.com (mail-vc0-x22d.google.com [2607:f8b0:400c:c03::22d])
        by mx.google.com with ESMTPS id mb10si11965697vcb.59.2014.07.21.10.42.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 10:42:00 -0700 (PDT)
Received: by mail-vc0-f173.google.com with SMTP id hy10so12858831vcb.18
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 10:41:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140721172331.GB4156@linux.vnet.ibm.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
	<20140721172331.GB4156@linux.vnet.ibm.com>
Date: Mon, 21 Jul 2014 10:41:59 -0700
Message-ID: <CA+8MBbK+ZdisT_yXh_jkWSd4hWEMisG614s4s0EyNV3j-7YOow@mail.gmail.com>
Subject: Re: [RFC Patch V1 00/30] Enable memoryless node on x86 platforms
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-hotplug@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Jul 21, 2014 at 10:23 AM, Nishanth Aravamudan
<nacc@linux.vnet.ibm.com> wrote:
> It seems like the issue is the order of onlining of resources on a
> specific x86 platform?

Yes. When we online a node the BIOS hits us with some ACPI hotplug events:

First: Here are some new cpus
Next: Here is some new memory
Last; Here are some new I/O things (PCIe root ports, PCIe devices,
IOAPICs, IOMMUs, ...)

So there is a period where the node is memoryless - although that will generally
be resolved when the memory hot plug event arrives ... that isn't guaranteed to
occur (there might not be any memory on the node, or what memory there is
may have failed self-test and been disabled).

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
