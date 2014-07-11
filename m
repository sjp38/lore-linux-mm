Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 968CC900002
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 11:33:36 -0400 (EDT)
Received: by mail-ie0-f181.google.com with SMTP id rp18so1022171iec.40
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 08:33:36 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d9si5521556icx.23.2014.07.11.08.33.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jul 2014 08:33:35 -0700 (PDT)
Date: Fri, 11 Jul 2014 08:33:14 -0700
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC Patch V1 00/30] Enable memoryless node on x86 platforms
Message-ID: <20140711153314.GA6155@kroah.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
 <20140711082956.GC20603@laptop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140711082956.GC20603@laptop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Jul 11, 2014 at 10:29:56AM +0200, Peter Zijlstra wrote:
> On Fri, Jul 11, 2014 at 03:37:17PM +0800, Jiang Liu wrote:
> > Any comments are welcomed!
> 
> Why would anybody _ever_ have a memoryless node? That's ridiculous.

I'm with Peter here, why would this be a situation that we should even
support?  Are there machines out there shipping like this?

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
