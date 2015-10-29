Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 032BA82F64
	for <linux-mm@kvack.org>; Wed, 28 Oct 2015 20:39:51 -0400 (EDT)
Received: by wmec75 with SMTP id c75so15010617wme.1
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 17:39:50 -0700 (PDT)
Received: from mail-wi0-x235.google.com (mail-wi0-x235.google.com. [2a00:1450:400c:c05::235])
        by mx.google.com with ESMTPS id z11si59303986wjy.93.2015.10.28.17.39.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Oct 2015 17:39:50 -0700 (PDT)
Received: by wikq8 with SMTP id q8so270746228wik.1
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 17:39:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CABXk95DOSKv70p+=DQvHck5LCvRDc0WDORpoobSStWhrcrCiyg@mail.gmail.com>
References: <1446067520-31806-1-git-send-email-dcashman@android.com>
	<871tcewoso.fsf@x220.int.ebiederm.org>
	<CABXk95DOSKv70p+=DQvHck5LCvRDc0WDORpoobSStWhrcrCiyg@mail.gmail.com>
Date: Wed, 28 Oct 2015 17:39:49 -0700
Message-ID: <CAEP4de2GsEwn0eeO126GEtFb-FSJoU3fgOWTAr1yPFAmyXTi0Q@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: mmap: Add new /proc tunable for mmap_base ASLR.
From: Dan Cashman <dcashman@android.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeffrey Vander Stoep <jeffv@google.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, linux@arm.linux.org.uk, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, Jonathan Corbet <corbet@lwn.net>, dzickus@redhat.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, Mel Gorman <mgorman@suse.de>, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, Mark Salyzyn <salyzyn@android.com>, Nick Kralevich <nnk@google.com>, dcashman <dcashman@google.com>

> > This all would be much cleaner if the arm architecture code were just to
> > register the sysctl itself.
> >
> > As it sits this looks like a patchset that does not meaninfully bisect,
> > and would result in code that is hard to trace and understand.
>
> I believe the intent is to follow up with more architecture specific
> patches to allow each architecture to define the number of bits to use

Yes.  I included these patches together because they provide mutual
context, but each has a different outcome and they could be taken
separately.  The arm architecture-specific portion allows the changing
of the number of bits used for mmap ASLR, useful even without the
sysctl.  The sysctl patch (patch 1) provides another way of setting
this value, and the hope is that this will be adopted across multiple
architectures, with the arm changes (patch 2) providing an example.  I
hope to follow this with changes to arm64 and x86, for example.

On Wed, Oct 28, 2015 at 5:01 PM, Jeffrey Vander Stoep <jeffv@google.com> wrote:
> plain text this time...
>
>> This all would be much cleaner if the arm architecture code were just to
>> register the sysctl itself.
>>
>> As it sits this looks like a patchset that does not meaninfully bisect,
>> and would result in code that is hard to trace and understand.
>
> I believe the intent is to follow up with more architecture specific
> patches to allow each architecture to define the number of bits to use
> (min, max, and default) since these values are architecture dependent.
> Arm64 patch should be forthcoming, and others after that. With that in
> mind, would you still prefer to have the sysctl code in the
> arm-specific patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
