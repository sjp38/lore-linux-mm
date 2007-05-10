Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id l4A475q3032628
	for <linux-mm@kvack.org>; Wed, 9 May 2007 21:07:05 -0700
Received: from py-out-1112.google.com (pyhf31.prod.google.com [10.34.233.31])
	by zps76.corp.google.com with ESMTP id l4A46sBx032289
	for <linux-mm@kvack.org>; Wed, 9 May 2007 21:06:54 -0700
Received: by py-out-1112.google.com with SMTP id f31so354797pyh
        for <linux-mm@kvack.org>; Wed, 09 May 2007 21:06:54 -0700 (PDT)
Message-ID: <65dd6fd50705092106i15722e97g85f43191ceb5a3d7@mail.gmail.com>
Date: Wed, 9 May 2007 21:06:53 -0700
From: "Ollie Wild" <aaw@google.com>
Subject: Re: [patch] removes MAX_ARG_PAGES
In-Reply-To: <200705092104.43353.rob@landley.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <65dd6fd50705060151m78bb9b4fpcb941b16a8c4709e@mail.gmail.com>
	 <20070509134815.81cb9aa9.akpm@linux-foundation.org>
	 <200705092104.43353.rob@landley.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rob Landley <rob@landley.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On 5/9/07, Rob Landley <rob@landley.net> wrote:
> Just FYI, a really really quick and dirty way of testing this sort of thing on
> more architectures and you're likely to physically have?

Does this properly emulate caching?  On parisc, cache coherency was
the main issue we ran into.  I suspect this might be the case with
other architectures as well.

Ollie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
