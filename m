Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id 5172F6B0032
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 08:20:32 -0500 (EST)
Received: by mail-qa0-f44.google.com with SMTP id n8so12586734qaq.3
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 05:20:30 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o10si4042533qgd.14.2015.02.27.05.20.29
        for <linux-mm@kvack.org>;
        Fri, 27 Feb 2015 05:20:29 -0800 (PST)
Date: Fri, 27 Feb 2015 13:20:00 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH V4 0/6] RCU get_user_pages_fast and __get_user_pages_fast
Message-ID: <20150227132000.GD9011@leverpostej>
References: <1411740233-28038-1-git-send-email-steve.capper@linaro.org>
 <54F06636.6080905@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54F06636.6080905@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jon Masters <jcm@redhat.com>
Cc: Steve Capper <steve.capper@linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Will Deacon <Will.Deacon@arm.com>, "gary.robertson@linaro.org" <gary.robertson@linaro.org>, "christoffer.dall@linaro.org" <christoffer.dall@linaro.org>, "peterz@infradead.org" <peterz@infradead.org>, "anders.roxell@linaro.org" <anders.roxell@linaro.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "dann.frazier@canonical.com" <dann.frazier@canonical.com>, "mgorman@suse.de" <mgorman@suse.de>, "hughd@google.com" <hughd@google.com>

Hi Jon,

Steve is currently away, but should be back in the office next week.

On Fri, Feb 27, 2015 at 12:42:30PM +0000, Jon Masters wrote:
> On 09/26/2014 10:03 AM, Steve Capper wrote:
> 
> > This series implements general forms of get_user_pages_fast and
> > __get_user_pages_fast in core code and activates them for arm and arm64.
> > 
> > These are required for Transparent HugePages to function correctly, as
> > a futex on a THP tail will otherwise result in an infinite loop (due to
> > the core implementation of __get_user_pages_fast always returning 0).
> > 
> > Unfortunately, a futex on THP tail can be quite common for certain
> > workloads; thus THP is unreliable without a __get_user_pages_fast
> > implementation.
> > 
> > This series may also be beneficial for direct-IO heavy workloads and
> > certain KVM workloads.
> > 
> > I appreciate that the merge window is coming very soon, and am posting
> > this revision on the off-chance that it gets the nod for 3.18. (The changes
> > thus far have been minimal and the feedback I've got has been mainly
> > positive).
> 
> Head's up: these patches are currently implicated in a rare-to-trigger
> hang that we are seeing on an internal kernel. An extensive effort is
> underway to confirm whether these are the cause. Will followup.

I'm currently investigating an intermittent memory corruption issue in
v4.0-rc1 I'm able to trigger on Seattle with 4K pages and 48-bit VA,
which may or may not be related. Sometimes it results in a hang (when
the vectors get corrupted and the CPUs get caught in a recursive
exception loop).

Which architecture(s) are you hitting this on?

Which configurations configuration(s)?

What are you using to tickle the issue?

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
