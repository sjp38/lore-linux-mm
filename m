Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id ACBB76B0071
	for <linux-mm@kvack.org>; Sun, 29 Mar 2015 06:24:47 -0400 (EDT)
Received: by wgbgs4 with SMTP id gs4so50363213wgb.0
        for <linux-mm@kvack.org>; Sun, 29 Mar 2015 03:24:47 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id ny6si2179435wic.43.2015.03.29.03.24.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Mar 2015 03:24:46 -0700 (PDT)
Date: Sun, 29 Mar 2015 12:24:40 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC] vmstat: Avoid waking up idle-cpu to service shepherd work
Message-ID: <20150329102440.GC32047@worktop.ger.corp.intel.com>
References: <359c926bc85cdf79650e39f2344c2083002545bb.1427347966.git.viresh.kumar@linaro.org>
 <20150326131822.fce6609efdd85b89ceb3f61c@linux-foundation.org>
 <CAKohpo=nTXutbVVf-7iAwtgya4zUL686XbG69ExQ3Pi=VQRE-A@mail.gmail.com>
 <20150327091613.GE27490@worktop.programming.kicks-ass.net>
 <20150327093023.GA32047@worktop.ger.corp.intel.com>
 <CAOh2x=nbisppmuBwfLWndyCPKem1N_KzoTxyAYcQuL77T_bJfw@mail.gmail.com>
 <20150328095322.GH27490@worktop.programming.kicks-ass.net>
 <55169723.3070006@linaro.org>
 <20150328134457.GK27490@worktop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150328134457.GK27490@worktop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viresh kumar <viresh.kumar@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, vinmenon@codeaurora.org, shashim@codeaurora.org, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, dave@stgolabs.net, Konstantin Khlebnikov <koct9i@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Suresh Siddha <suresh.b.siddha@intel.com>, Thomas Gleixner <tglx@linutronix.de>

On Sat, Mar 28, 2015 at 02:44:57PM +0100, Peter Zijlstra wrote:
> > Now there are few issues I see here (Sorry if they are all imaginary):
> > - In case a timer re-arms itself from its handler and is migrated from CPU A to B, what
> >   happens if the re-armed timer fires before the first handler finishes ? i.e. timer->fn()
> >   hasn't finished running on CPU A and it has fired again on CPU B. Wouldn't this expose
> >   us to a lot of other problems? It wouldn't be serialized to itself anymore ?
> 
> What I said above.

What I didn't say, but had thought of is that __run_timer() should skip
any timer that has RUNNING set -- for obvious reasons :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
