Date: Thu, 20 Jun 2002 10:22:20 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [kpreempt-tech] Re: Oops in kernel 2.4.19-pre10-ac2-preempt
Message-ID: <20020620172220.GT25360@holomorphy.com>
References: <OF4C1E1763.D4BE6432-ON86256BDE.0055BDB6@hou.us.ray.com> <20020620171652.GS25360@holomorphy.com> <1024593564.922.151.camel@sinai>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1024593564.922.151.camel@sinai>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: Mark_H_Johnson@Raytheon.com, kpreempt-tech@lists.sourceforge.net, linux-mm@kvack.org, Robert_Horton@Raytheon.com, James_P_Cassidy@Raytheon.com, Stanley_R_Allen@Raytheon.com
List-ID: <linux-mm.kvack.org>

On Thu, 2002-06-20 at 10:16, William Lee Irwin III wrote:
>> The preemption cleanup cannot be done on 2.4 as there are no preemption
>> disabling primitives available.

On Thu, Jun 20, 2002 at 10:19:24AM -0700, Robert Love wrote:
> wli, if you send me a patch (or just tell me explicitly where to enable
> and disable preemption) I will merge it into the 2.4-ac preempt
> patches...

That'd be great, the two places are pte_chain_lock() and pte_chain_unlock().
They're basically a spin_lock_bit() and spin_unlock_bit(), so they need
the same kind of disable preempt before the spinloop and re-enable it after
dropping the lock treatment as spinlocks.


Thanks,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
