Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f53.google.com (mail-oi0-f53.google.com [209.85.218.53])
	by kanga.kvack.org (Postfix) with ESMTP id DB8E36B0032
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 00:49:55 -0400 (EDT)
Received: by oicf142 with SMTP id f142so58084755oic.3
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 21:49:55 -0700 (PDT)
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com. [209.85.214.180])
        by mx.google.com with ESMTPS id r129si513899oia.126.2015.03.26.21.49.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 21:49:55 -0700 (PDT)
Received: by obcjt1 with SMTP id jt1so63121934obc.2
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 21:49:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150326131822.fce6609efdd85b89ceb3f61c@linux-foundation.org>
References: <359c926bc85cdf79650e39f2344c2083002545bb.1427347966.git.viresh.kumar@linaro.org>
	<20150326131822.fce6609efdd85b89ceb3f61c@linux-foundation.org>
Date: Fri, 27 Mar 2015 10:19:54 +0530
Message-ID: <CAKohpo=nTXutbVVf-7iAwtgya4zUL686XbG69ExQ3Pi=VQRE-A@mail.gmail.com>
Subject: Re: [RFC] vmstat: Avoid waking up idle-cpu to service shepherd work
From: Viresh Kumar <viresh.kumar@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: hannes@cmpxchg.org, Christoph Lameter <cl@linux.com>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, vinmenon@codeaurora.org, shashim@codeaurora.org, Michal Hocko <mhocko@suse.cz>, mgorman@suse.de, dave@stgolabs.net, koct9i@gmail.com, Linux Memory Management List <linux-mm@kvack.org>, Suresh Siddha <suresh.b.siddha@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On 27 March 2015 at 01:48, Andrew Morton <akpm@linux-foundation.org> wrote:
> Shouldn't this be viewed as a shortcoming of the core timer code?

Yeah, it is. Some (not so pretty) solutions were tried earlier to fix that, but
they are rejected for obviously reasons [1].

> vmstat_shepherd() is merely rescheduling itself with
> schedule_delayed_work().  That's a dead bog simple operation and if
> it's producing suboptimal behaviour then we shouldn't be fixing it with
> elaborate workarounds in the caller?

I understand that, and that's why I sent it as an RFC to get the discussion
started. Does anyone else have got another (acceptable) idea to get this
resolved ?

--
viresh

[1] http://lists.linaro.org/pipermail/linaro-kernel/2013-November/008866.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
