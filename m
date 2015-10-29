Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3C4A882F64
	for <linux-mm@kvack.org>; Wed, 28 Oct 2015 23:51:31 -0400 (EDT)
Received: by padhk11 with SMTP id hk11so26888126pad.1
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 20:51:30 -0700 (PDT)
Received: from out02.mta.xmission.com (out02.mta.xmission.com. [166.70.13.232])
        by mx.google.com with ESMTPS id em5si75150478pbd.203.2015.10.28.20.51.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 28 Oct 2015 20:51:30 -0700 (PDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <1446067520-31806-1-git-send-email-dcashman@android.com>
	<871tcewoso.fsf@x220.int.ebiederm.org>
	<CABXk95DOSKv70p+=DQvHck5LCvRDc0WDORpoobSStWhrcrCiyg@mail.gmail.com>
	<CAEP4de2GsEwn0eeO126GEtFb-FSJoU3fgOWTAr1yPFAmyXTi0Q@mail.gmail.com>
Date: Wed, 28 Oct 2015 22:41:35 -0500
In-Reply-To: <CAEP4de2GsEwn0eeO126GEtFb-FSJoU3fgOWTAr1yPFAmyXTi0Q@mail.gmail.com>
	(Dan Cashman's message of "Wed, 28 Oct 2015 17:39:49 -0700")
Message-ID: <87oafiuys0.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCH 1/2] mm: mmap: Add new /proc tunable for mmap_base ASLR.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Cashman <dcashman@android.com>
Cc: Jeffrey Vander Stoep <jeffv@google.com>, linux-kernel@vger.kernel.org, linux@arm.linux.org.uk, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, Jonathan Corbet <corbet@lwn.net>, dzickus@redhat.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, Mel Gorman <mgorman@suse.de>, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, Mark Salyzyn <salyzyn@android.com>, Nick Kralevich <nnk@google.com>, dcashman <dcashman@google.com>

Dan Cashman <dcashman@android.com> writes:

>> > This all would be much cleaner if the arm architecture code were just to
>> > register the sysctl itself.
>> >
>> > As it sits this looks like a patchset that does not meaninfully bisect,
>> > and would result in code that is hard to trace and understand.
>>
>> I believe the intent is to follow up with more architecture specific
>> patches to allow each architecture to define the number of bits to use
>
> Yes.  I included these patches together because they provide mutual
> context, but each has a different outcome and they could be taken
> separately.

They can not.  The first patch is incomplete by itself.

> The arm architecture-specific portion allows the changing
> of the number of bits used for mmap ASLR, useful even without the
> sysctl.  The sysctl patch (patch 1) provides another way of setting
> this value, and the hope is that this will be adopted across multiple
> architectures, with the arm changes (patch 2) providing an example.  I
> hope to follow this with changes to arm64 and x86, for example.

If you want to make the code generic.  Please maximize the sharing.
That is please define the variables in a generic location, as well
as the Kconfig variables (if possible).

As it is you have an architecture specific piece of code that can not be
reused without duplicating code, and that is just begging for problems.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
