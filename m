Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id EFED16B0035
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 16:02:34 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y10so1905388pdj.5
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 13:02:34 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id iw9si3443407pbd.234.2014.07.11.13.02.31
        for <linux-mm@kvack.org>;
        Fri, 11 Jul 2014 13:02:32 -0700 (PDT)
Message-ID: <53C042C6.2020507@intel.com>
Date: Fri, 11 Jul 2014 13:02:14 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC Patch V1 00/30] Enable memoryless node on x86 platforms
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com> <20140711082956.GC20603@laptop.programming.kicks-ass.net> <20140711153314.GA6155@kroah.com>
In-Reply-To: <20140711153314.GA6155@kroah.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>, Jiang Liu <jiang.liu@linux.intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

On 07/11/2014 08:33 AM, Greg KH wrote:
> On Fri, Jul 11, 2014 at 10:29:56AM +0200, Peter Zijlstra wrote:
>> > On Fri, Jul 11, 2014 at 03:37:17PM +0800, Jiang Liu wrote:
>>> > > Any comments are welcomed!
>> > 
>> > Why would anybody _ever_ have a memoryless node? That's ridiculous.
> I'm with Peter here, why would this be a situation that we should even
> support?  Are there machines out there shipping like this?

This is orthogonal to the problem Jiang Liu is solving, but...

The IBM guys have been hitting the CPU-less and memoryless node issues
forever, but that's mostly because their (traditional) hypervisor had
good NUMA support and ran multi-node guests.

I've never seen it in practice on x86 mostly because the hypervisors
don't have good NUMA support. I honestly think this is something x86 is
going to have to handle eventually anyway.  It's essentially a resource
fragmentation problem, and there are going to be times where a guest
needs to be spun up and hypervisor has nodes with either no spare memory
or no spare CPUs.

The hypervisor has 3 choices in this case:
1. Lie about the NUMA layout
2. Waste the resources
3. Tell the guest how it's actually arranged


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
