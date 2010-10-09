Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 00D816B0071
	for <linux-mm@kvack.org>; Sat,  9 Oct 2010 14:43:36 -0400 (EDT)
Message-ID: <4CB0B7C5.5030609@redhat.com>
Date: Sat, 09 Oct 2010 20:43:17 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 06/12] Add PV MSR to enable asynchronous page faults
 delivery.
References: <1286207794-16120-1-git-send-email-gleb@redhat.com> <1286207794-16120-7-git-send-email-gleb@redhat.com> <4CADC3F2.2050506@redhat.com> <20101007175943.GH2397@redhat.com>
In-Reply-To: <20101007175943.GH2397@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

  On 10/07/2010 07:59 PM, Gleb Natapov wrote:
> On Thu, Oct 07, 2010 at 02:58:26PM +0200, Avi Kivity wrote:
> >   On 10/04/2010 05:56 PM, Gleb Natapov wrote:
> >  >+
> >  >+	Physical address points to 32 bit memory location that will be written
> >  >+	to by the hypervisor at the time of asynchronous page fault injection to
> >  >+	indicate type of asynchronous page fault. Value of 1 means that the page
> >  >+	referred to by the page fault is not present. Value 2 means that the
> >  >+	page is now available.
> >
> >  "The must not enable interrupts before the reason is read, or it may
> >  be overwritten by another apf".
> >
> >  Document the fact that disabling interrupts disables APFs.
> >
> >  How does the guest distinguish betweem APFs and ordinary page faults?
> >
> >  What's the role of cr2?
> >
> >  When disabling APF, all pending APFs are flushed and may or may not
> >  get a completion.
> >
> >  Is a "page available" notification guaranteed to arrive on the same
> >  vcpu that took the "page not present" fault?
> >
> You mean documentation is lacking? :)
>

I mean you should be able to write guest support code without reading 
the host code, just the documentation.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
