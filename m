Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5F80A6B0035
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 17:58:44 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id t60so1677787wes.0
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 14:58:42 -0700 (PDT)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id vq2si6450853wjc.89.2014.07.11.14.58.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 11 Jul 2014 14:58:40 -0700 (PDT)
Date: Fri, 11 Jul 2014 23:58:37 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC Patch V1 00/30] Enable memoryless node on x86 platforms
Message-ID: <20140711215837.GU18735@two.firstfloor.org>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
 <20140711082956.GC20603@laptop.programming.kicks-ass.net>
 <20140711153314.GA6155@kroah.com>
 <8761j3ve8s.fsf@tassilo.jf.intel.com>
 <20140711205106.GB20603@laptop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140711205106.GB20603@laptop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andi Kleen <andi@firstfloor.org>, Greg KH <gregkh@linuxfoundation.org>, Jiang Liu <jiang.liu@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Jul 11, 2014 at 10:51:06PM +0200, Peter Zijlstra wrote:
> On Fri, Jul 11, 2014 at 01:20:51PM -0700, Andi Kleen wrote:
> > Greg KH <gregkh@linuxfoundation.org> writes:
> > 
> > > On Fri, Jul 11, 2014 at 10:29:56AM +0200, Peter Zijlstra wrote:
> > >> On Fri, Jul 11, 2014 at 03:37:17PM +0800, Jiang Liu wrote:
> > >> > Any comments are welcomed!
> > >> 
> > >> Why would anybody _ever_ have a memoryless node? That's ridiculous.
> > >
> > > I'm with Peter here, why would this be a situation that we should even
> > > support?  Are there machines out there shipping like this?
> > 
> > We've always had memory nodes.
> > 
> > A classic case in the old days was a two socket system where someone
> > didn't populate any DIMMs on the second socket.
> 
> That's a obvious; don't do that then case. Its silly.

True. We should recommend that anyone running Linux will email you
for approval of their configuration first.


> > There are other cases too.
> 
> Are there any sane ones

Yes.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
