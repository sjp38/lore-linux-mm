Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id A0DAF6B0032
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 07:11:47 -0400 (EDT)
Received: by igbud6 with SMTP id ud6so17068661igb.1
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 04:11:47 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id 41si1453024ioq.94.2015.03.27.04.11.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 27 Mar 2015 04:11:46 -0700 (PDT)
Date: Fri, 27 Mar 2015 06:11:44 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] vmstat: Avoid waking up idle-cpu to service shepherd
 work
In-Reply-To: <20150327093023.GA32047@worktop.ger.corp.intel.com>
Message-ID: <alpine.DEB.2.11.1503270610430.19514@gentwo.org>
References: <359c926bc85cdf79650e39f2344c2083002545bb.1427347966.git.viresh.kumar@linaro.org> <20150326131822.fce6609efdd85b89ceb3f61c@linux-foundation.org> <CAKohpo=nTXutbVVf-7iAwtgya4zUL686XbG69ExQ3Pi=VQRE-A@mail.gmail.com> <20150327091613.GE27490@worktop.programming.kicks-ass.net>
 <20150327093023.GA32047@worktop.ger.corp.intel.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Viresh Kumar <viresh.kumar@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, hannes@cmpxchg.org, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, vinmenon@codeaurora.org, shashim@codeaurora.org, Michal Hocko <mhocko@suse.cz>, mgorman@suse.de, dave@stgolabs.net, koct9i@gmail.com, Linux Memory Management List <linux-mm@kvack.org>, Suresh Siddha <suresh.b.siddha@intel.com>, Thomas Gleixner <tglx@linutronix.de>

On Fri, 27 Mar 2015, Peter Zijlstra wrote:

> > We could align the base on 8 bytes to gain an extra bit in the pointer
> > and use that bit to indicate the running state. Then these sites can
> > spin on that bit while we can change the actual base pointer.
>
> Even though tvec_base has ____cacheline_aligned stuck on, most are
> allocated using kzalloc_node() which does not actually respect that but
> already guarantees a minimum u64 alignment, so I think we can use that
> third bit without too much magic.

Create a new slab cache for this purpose that does the proper aligning?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
