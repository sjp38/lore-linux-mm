Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5C5B46B003D
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 05:21:51 -0500 (EST)
Date: Wed, 6 Jan 2010 12:21:29 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v3 00/12] KVM: Add host swap event notifications for PV
 guest
Message-ID: <20100106102129.GG4905@redhat.com>
References: <1262700774-1808-1-git-send-email-gleb@redhat.com>
 <fdaac4d51001050705s3f46dd0fi948a3b3ea803fa51@mail.gmail.com>
 <4B43631A.2030101@redhat.com>
 <fdaac4d51001060217h16ffb331mcc0db195630f4de4@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fdaac4d51001060217h16ffb331mcc0db195630f4de4@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Jun Koi <junkoi2004@gmail.com>
Cc: Avi Kivity <avi@redhat.com>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 06, 2010 at 07:17:30PM +0900, Jun Koi wrote:
> On Wed, Jan 6, 2010 at 1:04 AM, Avi Kivity <avi@redhat.com> wrote:
> > On 01/05/2010 05:05 PM, Jun Koi wrote:
> >>
> >> Is it true that to make this work, we will need a (PV) kernel driver
> >> for each guest OS (Windows, Linux, ...)?
> >>
> >>
> >
> > It's partially usable even without guest modifications; while servicing a
> > host page fault we can still deliver interrupts to the guest (which might
> > cause a context switch and thus further progress to be made).
> 
> Lets say, in the case the guest has no PV driver. When we find that a
> guest page is swapped out, we can send a pagefault
> to the guest to trick it to load that page in. And we dont need the
> driver at all.
> 
That's not the guest who should load the page. From guest's point of view the
page is in memory.

> Is that a reasonable solution?
> 
> Thanks,
> J

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
