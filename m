Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 53C166007E1
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 10:05:57 -0500 (EST)
Received: by pxi5 with SMTP id 5so11537607pxi.12
        for <linux-mm@kvack.org>; Tue, 05 Jan 2010 07:05:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1262700774-1808-1-git-send-email-gleb@redhat.com>
References: <1262700774-1808-1-git-send-email-gleb@redhat.com>
From: Jun Koi <junkoi2004@gmail.com>
Date: Wed, 6 Jan 2010 00:05:32 +0900
Message-ID: <fdaac4d51001050705s3f46dd0fi948a3b3ea803fa51@mail.gmail.com>
Subject: Re: [PATCH v3 00/12] KVM: Add host swap event notifications for PV
	guest
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 5, 2010 at 11:12 PM, Gleb Natapov <gleb@redhat.com> wrote:
> KVM virtualizes guest memory by means of shadow pages or HW assistance
> like NPT/EPT. Not all memory used by a guest is mapped into the guest
> address space or even present in a host memory at any given time.
> When vcpu tries to access memory page that is not mapped into the guest
> address space KVM is notified about it. KVM maps the page into the guest
> address space and resumes vcpu execution. If the page is swapped out
> from host memory vcpu execution is suspended till the page is not swapped
> into the memory again. This is inefficient since vcpu can do other work
> (run other task or serve interrupts) while page gets swapped in.
>
> To overcome this inefficiency this patch series implements "asynchronous
> page fault" for paravirtualized KVM guests. If a page that vcpu is
> trying to access is swapped out KVM sends an async PF to the vcpu
> and continues vcpu execution. Requested page is swapped in by another
> thread in parallel. =A0When vcpu gets async PF it puts faulted task to
> sleep until "wake up" interrupt is delivered. When the page is brought
> to the host memory KVM sends "wake up" interrupt and the guest's task
> resumes execution.
>

Is it true that to make this work, we will need a (PV) kernel driver
for each guest OS (Windows, Linux, ...)?

Thanks,
Jun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
