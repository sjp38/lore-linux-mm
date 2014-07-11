Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4D2F36B0035
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 16:51:15 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id r10so1951336pdi.23
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 13:51:15 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id bq15si1800331pdb.156.2014.07.11.13.51.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jul 2014 13:51:13 -0700 (PDT)
Date: Fri, 11 Jul 2014 22:51:06 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC Patch V1 00/30] Enable memoryless node on x86 platforms
Message-ID: <20140711205106.GB20603@laptop.programming.kicks-ass.net>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
 <20140711082956.GC20603@laptop.programming.kicks-ass.net>
 <20140711153314.GA6155@kroah.com>
 <8761j3ve8s.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8761j3ve8s.fsf@tassilo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Greg KH <gregkh@linuxfoundation.org>, Jiang Liu <jiang.liu@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Jul 11, 2014 at 01:20:51PM -0700, Andi Kleen wrote:
> Greg KH <gregkh@linuxfoundation.org> writes:
> 
> > On Fri, Jul 11, 2014 at 10:29:56AM +0200, Peter Zijlstra wrote:
> >> On Fri, Jul 11, 2014 at 03:37:17PM +0800, Jiang Liu wrote:
> >> > Any comments are welcomed!
> >> 
> >> Why would anybody _ever_ have a memoryless node? That's ridiculous.
> >
> > I'm with Peter here, why would this be a situation that we should even
> > support?  Are there machines out there shipping like this?
> 
> We've always had memory nodes.
> 
> A classic case in the old days was a two socket system where someone
> didn't populate any DIMMs on the second socket.

That's a obvious; don't do that then case. Its silly.

> There are other cases too.

Are there any sane ones?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
