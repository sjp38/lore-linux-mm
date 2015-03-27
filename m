Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id BE1266B0038
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 15:45:41 -0400 (EDT)
Received: by iecvj10 with SMTP id vj10so78863110iec.0
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 12:45:41 -0700 (PDT)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id kg16si2571742icb.52.2015.03.27.12.45.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 27 Mar 2015 12:45:40 -0700 (PDT)
Date: Fri, 27 Mar 2015 14:45:36 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] vmstat: Avoid waking up idle-cpu to service shepherd
 work
In-Reply-To: <20150327120240.GC23123@twins.programming.kicks-ass.net>
Message-ID: <alpine.DEB.2.11.1503271444460.23488@gentwo.org>
References: <359c926bc85cdf79650e39f2344c2083002545bb.1427347966.git.viresh.kumar@linaro.org> <20150326131822.fce6609efdd85b89ceb3f61c@linux-foundation.org> <CAKohpo=nTXutbVVf-7iAwtgya4zUL686XbG69ExQ3Pi=VQRE-A@mail.gmail.com> <20150327091613.GE27490@worktop.programming.kicks-ass.net>
 <20150327093023.GA32047@worktop.ger.corp.intel.com> <alpine.DEB.2.11.1503270610430.19514@gentwo.org> <20150327120240.GC23123@twins.programming.kicks-ass.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Viresh Kumar <viresh.kumar@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, hannes@cmpxchg.org, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, vinmenon@codeaurora.org, shashim@codeaurora.org, Michal Hocko <mhocko@suse.cz>, mgorman@suse.de, dave@stgolabs.net, koct9i@gmail.com, Linux Memory Management List <linux-mm@kvack.org>, Suresh Siddha <suresh.b.siddha@intel.com>, Thomas Gleixner <tglx@linutronix.de>

On Fri, 27 Mar 2015, Peter Zijlstra wrote:

> On Fri, Mar 27, 2015 at 06:11:44AM -0500, Christoph Lameter wrote:
> >
> > Create a new slab cache for this purpose that does the proper aligning?
>
> That is certainly a possibility, but we'll only ever allocate nr_cpus-1
> entries from it, a whole new slab cache might be overkill.

This will certainly be aliased to some other slab cache so not much
overhead is created.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
