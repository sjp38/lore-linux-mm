Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 99D556B0035
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 21:18:11 -0400 (EDT)
Received: by mail-ie0-f181.google.com with SMTP id rp18so3985276iec.12
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 18:18:11 -0700 (PDT)
Received: from mail-ie0-x236.google.com (mail-ie0-x236.google.com [2607:f8b0:4001:c03::236])
        by mx.google.com with ESMTPS id z5si14235351igw.50.2014.07.14.18.18.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 14 Jul 2014 18:18:11 -0700 (PDT)
Received: by mail-ie0-f182.google.com with SMTP id y20so4041561ier.13
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 18:18:10 -0700 (PDT)
Date: Mon, 14 Jul 2014 18:18:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC Patch V1 00/30] Enable memoryless node on x86 platforms
In-Reply-To: <20140711205106.GB20603@laptop.programming.kicks-ass.net>
Message-ID: <alpine.DEB.2.02.1407141814090.8808@chino.kir.corp.google.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com> <20140711082956.GC20603@laptop.programming.kicks-ass.net> <20140711153314.GA6155@kroah.com> <8761j3ve8s.fsf@tassilo.jf.intel.com>
 <20140711205106.GB20603@laptop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andi Kleen <andi@firstfloor.org>, Greg KH <gregkh@linuxfoundation.org>, Jiang Liu <jiang.liu@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Mike Galbraith <umgwanakikbuti@gmail.com>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, 11 Jul 2014, Peter Zijlstra wrote:

> > There are other cases too.
> 
> Are there any sane ones?
> 

They are specifically allowed by the ACPI specification to be able to 
include only cpus, I/O, networking cards, etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
