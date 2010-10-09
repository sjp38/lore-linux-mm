Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3960A6B0071
	for <linux-mm@kvack.org>; Sat,  9 Oct 2010 14:48:35 -0400 (EDT)
Message-ID: <4CB0B8EF.3050702@redhat.com>
Date: Sat, 09 Oct 2010 20:48:15 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 08/12] Handle async PF in a guest.
References: <1286207794-16120-1-git-send-email-gleb@redhat.com> <1286207794-16120-9-git-send-email-gleb@redhat.com> <4CADC6C3.3040305@redhat.com> <20101007171418.GA2397@redhat.com> <4CAE00CB.1070400@redhat.com> <20101007180340.GI2397@redhat.com>
In-Reply-To: <20101007180340.GI2397@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

  On 10/07/2010 08:03 PM, Gleb Natapov wrote:
> >  >>
> >  >Host side keeps track of outstanding apfs and will not send apf for the
> >  >same phys address twice. It will halt vcpu instead.
> >
> >  What about different pages, running the scheduler code?
> >
> We can get couple of nested apfs, just like we can get nested
> interrupts. Since scheduler disables preemption second apf will halt.

How much is a couple?

Consider:

SIGSTOP
Entire process swapped out
SIGCONT

We can get APF's on the current code, the scheduler code, the stack, any 
debugging code in between (e.g. ftrace), and the page tables for all of 
these.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
