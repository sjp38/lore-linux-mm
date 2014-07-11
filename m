Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id AC07F6B0035
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 18:40:50 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id d1so382007wiv.1
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 15:40:50 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c11si6596070wjs.107.2014.07.11.15.40.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 11 Jul 2014 15:40:48 -0700 (PDT)
Date: Sat, 12 Jul 2014 00:40:40 +0200 (CEST)
From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [RFC Patch V1 00/30] Enable memoryless node on x86 platforms
In-Reply-To: <20140711153314.GA6155@kroah.com>
Message-ID: <alpine.LRH.2.00.1407120039120.17906@twin.jikos.cz>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com> <20140711082956.GC20603@laptop.programming.kicks-ass.net> <20140711153314.GA6155@kroah.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, 11 Jul 2014, Greg KH wrote:

> > On Fri, Jul 11, 2014 at 03:37:17PM +0800, Jiang Liu wrote:
> > > Any comments are welcomed!
> > 
> > Why would anybody _ever_ have a memoryless node? That's ridiculous.
> 
> I'm with Peter here, why would this be a situation that we should even
> support?  Are there machines out there shipping like this?

I am pretty sure I've seen ppc64 machine with memoryless NUMA node.

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
