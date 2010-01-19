Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CBDB36B006A
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 15:13:54 -0500 (EST)
Message-ID: <4B5611A9.4050301@zytor.com>
Date: Tue, 19 Jan 2010 12:10:17 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 04/12] Add "handle page fault" PV helper.
References: <1262700774-1808-1-git-send-email-gleb@redhat.com> <1262700774-1808-5-git-send-email-gleb@redhat.com> <1263490267.4244.340.camel@laptop> <20100117144411.GI31692@redhat.com> <4B541D08.9040802@zytor.com> <20100118085022.GA30698@redhat.com> <4B5510B1.9010202@zytor.com> <20100119065537.GF14345@redhat.com> <4B55E5D8.1070402@zytor.com> <20100119174438.GA19450@redhat.com>
In-Reply-To: <20100119174438.GA19450@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, tglx@linutronix.de, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On 01/19/2010 09:44 AM, Gleb Natapov wrote:
> 
> Yes it can be done this way and I'll look into it once more. Using
> exception vector is more convenient for three reasons: it allows to pass
> additional data in error code, it doesn't require guest to issue EOI,
> exception can be injected when interrupts are disabled by a guest. The
> last one is not important for now since host doesn't inject notifications
> when interrupts are disabled currently. Having Intel allocate one
> exception vector for hypervisor use would be really nice though.
> 

That's probably not going to happen, for the rather obvious reason: *you
already have 224 of them*.

You seem to be thinking here that vectors 0-31 have to be exceptions and
32-255 have to be interrupts.  *There is no such distinction*; the only
thing special about 0-31 is that we (Intel) reserve the right to control
the assignments; for 32-255 the platform and OS control the assignment.

You can have the guest OS take an exception on a vector above 31 just
fine; you just need it to tell the hypervisor which vector it, the OS,
assigned for this purpose.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
