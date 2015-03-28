Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 9A03A6B0038
	for <linux-mm@kvack.org>; Sat, 28 Mar 2015 00:28:39 -0400 (EDT)
Received: by oifl3 with SMTP id l3so91724113oif.0
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 21:28:39 -0700 (PDT)
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com. [209.85.218.45])
        by mx.google.com with ESMTPS id h3si2290819obz.71.2015.03.27.21.28.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Mar 2015 21:28:38 -0700 (PDT)
Received: by oifl3 with SMTP id l3so91724035oif.0
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 21:28:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150327120240.GC23123@twins.programming.kicks-ass.net>
References: <359c926bc85cdf79650e39f2344c2083002545bb.1427347966.git.viresh.kumar@linaro.org>
	<20150326131822.fce6609efdd85b89ceb3f61c@linux-foundation.org>
	<CAKohpo=nTXutbVVf-7iAwtgya4zUL686XbG69ExQ3Pi=VQRE-A@mail.gmail.com>
	<20150327091613.GE27490@worktop.programming.kicks-ass.net>
	<20150327093023.GA32047@worktop.ger.corp.intel.com>
	<alpine.DEB.2.11.1503270610430.19514@gentwo.org>
	<20150327120240.GC23123@twins.programming.kicks-ass.net>
Date: Sat, 28 Mar 2015 09:58:38 +0530
Message-ID: <CAKohpomiqOcmZe+tAPNv_kX=+FmtMu8K=Qgze1y2SvgJ1A16NQ@mail.gmail.com>
Subject: Re: [RFC] vmstat: Avoid waking up idle-cpu to service shepherd work
From: Viresh Kumar <viresh.kumar@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, vinmenon@codeaurora.org, shashim@codeaurora.org, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, dave@stgolabs.net, Konstantin Khlebnikov <koct9i@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Suresh Siddha <suresh.b.siddha@intel.com>, Thomas Gleixner <tglx@linutronix.de>

On 27 March 2015 at 17:32, Peter Zijlstra <peterz@infradead.org> wrote:
> What's not clear to me is why that thing is allocated at all, AFAICT
> something like:
>
> static DEFINE_PER_CPU(struct tvec_base, tvec_bases);
>
> Should do the right thing and be much simpler.

Does this comment from timers.c answers your query ?

                        /*
                         * This is for the boot CPU - we use compile-time
                         * static initialisation because per-cpu memory isn't
                         * ready yet and because the memory allocators are not
                         * initialised either.
                         */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
