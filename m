Subject: Re: 2.5.40-mm2
From: Robert Love <rml@tech9.net>
In-Reply-To: <3DA0BA33.5B295A46@digeo.com>
References: <3DA0B422.C23B23D4@digeo.com>
	<1033943021.27093.29.camel@phantasy>  <3DA0BA33.5B295A46@digeo.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 06 Oct 2002 18:38:05 -0400
Message-Id: <1033943886.26955.33.camel@phantasy>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, 2002-10-06 at 18:33, Andrew Morton wrote:

> I think it's a way of doing "cond_resched() if cond_resched() is
> a legal thing to do right now".
> 
> I'm sure David isn't using preempt though.


If the system is preemptible, then the call can be replaced with
preempt_check_resched() which avoids the unneeded inc and dec.

But if the system is preemptible, it probably does not accomplish much
because we will already have preempted (e.g. the interrupt handler that
woke up a new task set need_resched and on return from interrupt we
serviced it).

If the system is not preemptible (non-zero preempt_count here) this
accomplishes nothing.

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
