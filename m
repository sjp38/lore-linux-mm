Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id 731536B0035
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 19:52:05 -0400 (EDT)
Received: by mail-yk0-f172.google.com with SMTP id 10so376918ykt.31
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 16:52:05 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id a4si7542339yhd.129.2014.07.11.16.52.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jul 2014 16:52:04 -0700 (PDT)
Message-ID: <53C07865.2040103@zytor.com>
Date: Fri, 11 Jul 2014 16:51:01 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC Patch V1 00/30] Enable memoryless node on x86 platforms
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>	<20140711082956.GC20603@laptop.programming.kicks-ass.net>	<20140711153314.GA6155@kroah.com> <8761j3ve8s.fsf@tassilo.jf.intel.com>
In-Reply-To: <8761j3ve8s.fsf@tassilo.jf.intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>, Greg KH <gregkh@linuxfoundation.org>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

On 07/11/2014 01:20 PM, Andi Kleen wrote:
> Greg KH <gregkh@linuxfoundation.org> writes:
> 
>> On Fri, Jul 11, 2014 at 10:29:56AM +0200, Peter Zijlstra wrote:
>>> On Fri, Jul 11, 2014 at 03:37:17PM +0800, Jiang Liu wrote:
>>>> Any comments are welcomed!
>>>
>>> Why would anybody _ever_ have a memoryless node? That's ridiculous.
>>
>> I'm with Peter here, why would this be a situation that we should even
>> support?  Are there machines out there shipping like this?
> 
> We've always had memory nodes.
> 
> A classic case in the old days was a two socket system where someone
> didn't populate any DIMMs on the second socket.
> 
> There are other cases too.
> 

Yes, like a node controller-based system where the system can be
populated with either memory cards or CPU cards, for example.  Now you
can have both memoryless nodes and memory-only nodes...

Memory-only nodes also happen in real life.  In some cases they are done
by permanently putting low-frequency CPUs to sleep for their memory
controllers.
	
	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
