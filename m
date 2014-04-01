Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8B7256B0036
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 14:31:43 -0400 (EDT)
Received: by mail-we0-f175.google.com with SMTP id q58so6771536wes.34
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 11:31:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id fv2si10336855wib.104.2014.04.01.11.31.41
        for <linux-mm@kvack.org>;
        Tue, 01 Apr 2014 11:31:42 -0700 (PDT)
Message-ID: <533B0603.7040301@redhat.com>
Date: Tue, 01 Apr 2014 14:31:31 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86,mm: delay TLB flush after clearing accessed bit
References: <20140331113442.0d628362@annuminas.surriel.com>	<CA+55aFzG=B3t_YaoCY_H1jmEgs+cYd--ZHz7XhGeforMRvNfEQ@mail.gmail.com>	<533AE518.1090705@redhat.com> <CA+55aFx9KYTV_N3qjV6S9uu6iTiVZimXhZtUa9UYRkNR9P-7RQ@mail.gmail.com>
In-Reply-To: <CA+55aFx9KYTV_N3qjV6S9uu6iTiVZimXhZtUa9UYRkNR9P-7RQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, shli@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>

On 04/01/2014 12:21 PM, Linus Torvalds wrote:
> On Tue, Apr 1, 2014 at 9:11 AM, Rik van Riel <riel@redhat.com> wrote:
>>
>> Memory pressure is not necessarily caused by the same process
>> whose accessed bit we just cleared. Memory pressure may not
>> even be caused by any process's virtual memory at all, but it
>> could be caused by the page cache.
> 
> If we have that much memory pressure on the page cache without having
> any memory pressure on the actual VM space, then the swap-out activity
> will never be an issue anyway.
> 
> IOW, I think all these scenarios are made-up. I'd much rather go for
> simpler implementation, and make things more complex only in the
> presence of numbers. Of which we have none.

We've been bitten by the lack of a properly tracked accessed
bit before, but admittedly that was with the KVM code and EPT.

I'll add my Acked-by: to Shaohua's original patch then, and
will keep my eyes open for any problems that may or may not
materialize...

Shaohua?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
