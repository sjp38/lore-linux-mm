Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f51.google.com (mail-oa0-f51.google.com [209.85.219.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5A5726B0055
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 19:34:22 -0400 (EDT)
Received: by mail-oa0-f51.google.com with SMTP id i4so2765029oah.24
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 16:34:22 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id wu5si5532858oeb.121.2014.04.03.16.34.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 03 Apr 2014 16:34:21 -0700 (PDT)
Message-ID: <1396568057.4661.38.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [RFC] mm,tracing: improve current situation
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Thu, 03 Apr 2014 16:34:17 -0700
In-Reply-To: <533DE12C.9030203@intel.com>
References: <1396561440.4661.33.camel@buesod1.americas.hpqcorp.net>
	 <533DE12C.9030203@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Jones <davej@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 2014-04-03 at 15:31 -0700, Dave Hansen wrote:
> On 04/03/2014 02:44 PM, Davidlohr Bueso wrote:
> > Now, on a more general scenario, I basically would like to know, 1) is
> > this actually useful... I'm hoping that, if in fact something like this
> > gets merged, it won't just sit there. 2) What other general data would
> > be useful for debugging purposes? I'm happy to collect feedback and send
> > out something we can all benefit from.
> 
> One thing that would be nice, specifically for the VM, would be to turn
> all of the things that touch the /proc/vmstat counters
> (count_vm_event(), etc...) in to tracepoints.

Hmm what would be the difference? what's the issue with /proc/vmstat? I
guess for one, some of the stats depend on build rules (ie TLB flushing
statistics).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
