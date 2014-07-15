Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id AAB9F6B0035
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 21:19:58 -0400 (EDT)
Received: by mail-ig0-f172.google.com with SMTP id h15so2385742igd.11
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 18:19:58 -0700 (PDT)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id m18si14257528igk.36.2014.07.14.18.19.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 14 Jul 2014 18:19:58 -0700 (PDT)
Received: by mail-ig0-f169.google.com with SMTP id r2so2256015igi.2
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 18:19:57 -0700 (PDT)
Date: Mon, 14 Jul 2014 18:19:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC Patch V1 00/30] Enable memoryless node on x86 platforms
In-Reply-To: <alpine.LRH.2.00.1407120039120.17906@twin.jikos.cz>
Message-ID: <alpine.DEB.2.02.1407141818590.8808@chino.kir.corp.google.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com> <20140711082956.GC20603@laptop.programming.kicks-ass.net> <20140711153314.GA6155@kroah.com> <alpine.LRH.2.00.1407120039120.17906@twin.jikos.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jkosina@suse.cz>
Cc: Greg KH <gregkh@linuxfoundation.org>, Jiang Liu <jiang.liu@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Mike Galbraith <umgwanakikbuti@gmail.com>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tony Luck <tony.luck@intel.com>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

On Sat, 12 Jul 2014, Jiri Kosina wrote:

> I am pretty sure I've seen ppc64 machine with memoryless NUMA node.
> 

Yes, Nishanth Aravamudan (now cc'd) has been working diligently on the 
problems that have been encountered, including problems in generic kernel 
code, on powerpc with memoryless nodes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
