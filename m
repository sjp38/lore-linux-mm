Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id CFE916B0071
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 11:42:59 -0400 (EDT)
Received: by iedm5 with SMTP id m5so121049355ied.3
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 08:42:59 -0700 (PDT)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id lp9si9595048igb.52.2015.03.30.08.42.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 30 Mar 2015 08:42:59 -0700 (PDT)
Date: Mon, 30 Mar 2015 10:42:55 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] vmstat: Avoid waking up idle-cpu to service shepherd
 work
In-Reply-To: <20150330150818.GE3909@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.11.1503301041400.7251@gentwo.org>
References: <359c926bc85cdf79650e39f2344c2083002545bb.1427347966.git.viresh.kumar@linaro.org> <20150326131822.fce6609efdd85b89ceb3f61c@linux-foundation.org> <CAKohpo=nTXutbVVf-7iAwtgya4zUL686XbG69ExQ3Pi=VQRE-A@mail.gmail.com> <20150327091613.GE27490@worktop.programming.kicks-ass.net>
 <20150327093023.GA32047@worktop.ger.corp.intel.com> <CAOh2x=nbisppmuBwfLWndyCPKem1N_KzoTxyAYcQuL77T_bJfw@mail.gmail.com> <20150328095322.GH27490@worktop.programming.kicks-ass.net> <20150330150818.GE3909@dhcp22.suse.cz>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Peter Zijlstra <peterz@infradead.org>, Viresh Kumar <viresh.kumar@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, hannes@cmpxchg.org, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, vinmenon@codeaurora.org, shashim@codeaurora.org, mgorman@suse.de, dave@stgolabs.net, koct9i@gmail.com, Linux Memory Management List <linux-mm@kvack.org>, Suresh Siddha <suresh.b.siddha@intel.com>, Thomas Gleixner <tglx@linutronix.de>

On Mon, 30 Mar 2015, Michal Hocko wrote:

> Why cannot we do something like refresh_cpu_vm_stats from the IRQ
> context?  Especially the first zone stat part. The per-cpu pagesets is
> more costly and it would need a special treatment, alright. A simple
> way would be to splice the lists from the per-cpu context and then free
> those pages from the kthread context.

That would work.

> I am still wondering why those two things were squashed into a single
> place. Why kswapd is not doing the pcp cleanup?

They were squashed together by me for conveniences sake. They could be
separated. AFAICT the pcp cleanup could be done only on demand and we
already have logic for that when flushihng via IPI.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
