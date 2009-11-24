Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A31926B0082
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 16:04:05 -0500 (EST)
Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id nAOL40N7023929
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 13:04:00 -0800
Received: from pwj19 (pwj19.prod.google.com [10.241.219.83])
	by zps76.corp.google.com with ESMTP id nAOL3O3I020530
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 13:03:57 -0800
Received: by pwj19 with SMTP id 19so4740882pwj.14
        for <linux-mm@kvack.org>; Tue, 24 Nov 2009 13:03:57 -0800 (PST)
Date: Tue, 24 Nov 2009 13:03:55 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: lockdep complaints in slab allocator
In-Reply-To: <1259096519.4531.1809.camel@laptop>
Message-ID: <alpine.DEB.2.00.0911241302370.6593@chino.kir.corp.google.com>
References: <84144f020911192249l6c7fa495t1a05294c8f5b6ac8@mail.gmail.com> <1258709153.11284.429.camel@laptop> <84144f020911200238w3d3ecb38k92ca595beee31de5@mail.gmail.com> <1258714328.11284.522.camel@laptop> <4B067816.6070304@cs.helsinki.fi>
 <1258729748.4104.223.camel@laptop> <1259002800.5630.1.camel@penberg-laptop> <1259003425.17871.328.camel@calx> <4B0ADEF5.9040001@cs.helsinki.fi> <1259080406.4531.1645.camel@laptop> <20091124170032.GC6831@linux.vnet.ibm.com> <1259082756.17871.607.camel@calx>
  <1259086459.4531.1752.camel@laptop> <1259090615.17871.696.camel@calx>  <1259095580.4531.1788.camel@laptop> <1259096004.17871.716.camel@calx> <1259096519.4531.1809.camel@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Matt Mackall <mpm@selenic.com>, paulmck@linux.vnet.ibm.com, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Nov 2009, Peter Zijlstra wrote:

> Merge SLQB and rm mm/sl[ua]b.c include/linux/sl[ua]b.h for .33-rc1
> 

slqb still has a 5-10% performance regression compared to slab for 
benchmarks such as netperf TCP_RR on machines with high cpu counts, 
forcing that type of regression isn't acceptable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
