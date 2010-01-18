Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 716D96B006A
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 04:53:26 -0500 (EST)
Subject: Re: [PATCH v3 04/12] Add "handle page fault" PV helper.
From: Andi Kleen <andi@firstfloor.org>
References: <1262700774-1808-1-git-send-email-gleb@redhat.com>
	<1262700774-1808-5-git-send-email-gleb@redhat.com>
	<1263490267.4244.340.camel@laptop> <20100117144411.GI31692@redhat.com>
	<1263740980.557.20980.camel@twins>
Date: Mon, 18 Jan 2010 10:53:20 +0100
In-Reply-To: <1263740980.557.20980.camel@twins> (Peter Zijlstra's message of "Sun, 17 Jan 2010 16:09:40 +0100")
Message-ID: <87ljfv4u3z.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Gleb Natapov <gleb@redhat.com>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Peter Zijlstra <peterz@infradead.org> writes:
>
> Whatever are we doing to end up in do_page_fault() as it stands? Surely
> we can tell the CPU to go elsewhere to handle faults?
>
> Isn't that as simple as calling set_intr_gate(14, my_page_fault)
> somewhere on the cpuinit instead of the regular page_fault handler?

That typically requires ugly ifdefs in entry*S and could be described
as code obfuscation ("come from")

As long as he avoids a global reference (patch) the if should be practially
free anyways.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
