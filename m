Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8DB1282F64
	for <linux-mm@kvack.org>; Wed, 28 Oct 2015 20:01:38 -0400 (EDT)
Received: by oiao187 with SMTP id o187so14738385oia.3
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 17:01:38 -0700 (PDT)
Received: from mail-ob0-x22e.google.com (mail-ob0-x22e.google.com. [2607:f8b0:4003:c01::22e])
        by mx.google.com with ESMTPS id a6si29046572oeu.84.2015.10.28.17.01.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Oct 2015 17:01:37 -0700 (PDT)
Received: by obbza9 with SMTP id za9so20623643obb.1
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 17:01:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <871tcewoso.fsf@x220.int.ebiederm.org>
References: <1446067520-31806-1-git-send-email-dcashman@android.com>
	<871tcewoso.fsf@x220.int.ebiederm.org>
Date: Wed, 28 Oct 2015 17:01:37 -0700
Message-ID: <CABXk95DOSKv70p+=DQvHck5LCvRDc0WDORpoobSStWhrcrCiyg@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: mmap: Add new /proc tunable for mmap_base ASLR.
From: Jeffrey Vander Stoep <jeffv@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Daniel Cashman <dcashman@android.com>, linux-kernel@vger.kernel.org, linux@arm.linux.org.uk, Andrew Morton <akpm@linux-foundation.org>, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, Nick Kralevich <nnk@google.com>, dcashman <dcashman@google.com>

plain text this time...

> This all would be much cleaner if the arm architecture code were just to
> register the sysctl itself.
>
> As it sits this looks like a patchset that does not meaninfully bisect,
> and would result in code that is hard to trace and understand.

I believe the intent is to follow up with more architecture specific
patches to allow each architecture to define the number of bits to use
(min, max, and default) since these values are architecture dependent.
Arm64 patch should be forthcoming, and others after that. With that in
mind, would you still prefer to have the sysctl code in the
arm-specific patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
