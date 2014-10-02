Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8A7F86B0038
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 12:55:19 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id dc16so2073571qab.7
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 09:55:19 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c20si8272118qax.63.2014.10.02.09.55.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Oct 2014 09:55:18 -0700 (PDT)
Date: Thu, 2 Oct 2014 18:54:30 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH V4 1/6] mm: Introduce a general RCU get_user_pages_fast.
Message-ID: <20141002165430.GK2342@redhat.com>
References: <1411740233-28038-1-git-send-email-steve.capper@linaro.org>
 <1411740233-28038-2-git-send-email-steve.capper@linaro.org>
 <20141002121902.GA2342@redhat.com>
 <CAPvkgC3VkmctmD9dROqkAEwi-Njm9zQqVx1=Byttr5_n-J7wYw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPvkgC3VkmctmD9dROqkAEwi-Njm9zQqVx1=Byttr5_n-J7wYw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>, Gary Robertson <gary.robertson@linaro.org>, Christoffer Dall <christoffer.dall@linaro.org>, Peter Zijlstra <peterz@infradead.org>, Anders Roxell <anders.roxell@linaro.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Dann Frazier <dann.frazier@canonical.com>, Mark Rutland <mark.rutland@arm.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>

On Thu, Oct 02, 2014 at 11:18:00PM +0700, Steve Capper wrote:
> mm/gup.c was recently created?
> It may even make sense to move the weak version in a future patch?

I think the __weak stuff tends to go in lib, that's probably why it's
there. I don't mind either ways.

> I'm currently on holiday and have very limited access to email, I'd
> appreciate it if someone can keep an eye out for this during the merge
> window if this conflict arises?

No problem, I assume Andrew will merge your patchset first, so I can
resubmit against -mm patching the gup_fast_rcu too.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
