Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 594026B0098
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 09:26:54 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id y13so9614134pdi.7
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 06:26:54 -0700 (PDT)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id rs11si1527196pab.201.2014.09.11.06.26.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 11 Sep 2014 06:26:53 -0700 (PDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so5569747pdj.36
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 06:26:53 -0700 (PDT)
Date: Thu, 11 Sep 2014 06:25:09 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v4 2/2] ksm: provide support to use deferrable timers
 for scanner thread
In-Reply-To: <541156C9.1080203@codeaurora.org>
Message-ID: <alpine.LSU.2.11.1409110609320.2465@eggly.anvils>
References: <1408536628-29379-1-git-send-email-cpandya@codeaurora.org> <1408536628-29379-2-git-send-email-cpandya@codeaurora.org> <alpine.LSU.2.11.1408272258050.10518@eggly.anvils> <20140903095815.GK4783@worktop.ger.corp.intel.com>
 <alpine.LSU.2.11.1409080023100.1610@eggly.anvils> <20140908093949.GZ6758@twins.programming.kicks-ass.net> <alpine.LSU.2.11.1409091225310.8432@eggly.anvils> <541156C9.1080203@codeaurora.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chintan Pandya <cpandya@codeaurora.org>
Cc: Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, John Stultz <john.stultz@linaro.org>, Ingo Molnar <mingo@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>

On Thu, 11 Sep 2014, Chintan Pandya wrote:

> I don't mean to divert the thread too much. But just one suggestion offered
> by Harshad.
> 
> Why can't we stop invoking more of a KSM scanner thread when we are
> saturating from savings ? But again, to check whether savings are saturated
> or not, we may still want to rely upon timers and we have to wake the CPUs up
> from IDLE state.

I agree that it should make sense for KSM to slow down when it sees it's
making no progress (though that would depart from the pages_to_scan and
sleep_millisecs prescription - perhaps could be tied to sleep_millisecs 0).

But not stop.  That's the problem we're mainly concerned with here:
to save power we need it to stop, but then how to wake up, without
putting nasty hooks in hot paths for a minority interest?
I don't see an answer to that above.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
