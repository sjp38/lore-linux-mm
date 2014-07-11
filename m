Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id A6E266B0035
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 16:21:24 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id p10so1615974pdj.13
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 13:21:24 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id j4si1760435pdb.273.2014.07.11.13.21.21
        for <linux-mm@kvack.org>;
        Fri, 11 Jul 2014 13:21:22 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC Patch V1 00/30] Enable memoryless node on x86 platforms
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
	<20140711082956.GC20603@laptop.programming.kicks-ass.net>
	<20140711153314.GA6155@kroah.com>
Date: Fri, 11 Jul 2014 13:20:51 -0700
In-Reply-To: <20140711153314.GA6155@kroah.com> (Greg KH's message of "Fri, 11
	Jul 2014 08:33:14 -0700")
Message-ID: <8761j3ve8s.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

Greg KH <gregkh@linuxfoundation.org> writes:

> On Fri, Jul 11, 2014 at 10:29:56AM +0200, Peter Zijlstra wrote:
>> On Fri, Jul 11, 2014 at 03:37:17PM +0800, Jiang Liu wrote:
>> > Any comments are welcomed!
>> 
>> Why would anybody _ever_ have a memoryless node? That's ridiculous.
>
> I'm with Peter here, why would this be a situation that we should even
> support?  Are there machines out there shipping like this?

We've always had memory nodes.

A classic case in the old days was a two socket system where someone
didn't populate any DIMMs on the second socket.

There are other cases too.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
