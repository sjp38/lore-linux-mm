Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 5C4DA6B005A
	for <linux-mm@kvack.org>; Fri, 13 Jul 2012 19:09:12 -0400 (EDT)
Received: by qadz32 with SMTP id z32so702917qad.14
        for <linux-mm@kvack.org>; Fri, 13 Jul 2012 16:09:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120713154519.60a686e8.akpm@linux-foundation.org>
References: <1342139517-3451-1-git-send-email-walken@google.com>
	<1342139517-3451-6-git-send-email-walken@google.com>
	<20120713131514.86ab4df4.akpm@linux-foundation.org>
	<CANN689FUm83vGFVF30Lg52_28vxdY+mZ88jVCGpmVfiHiHwNtg@mail.gmail.com>
	<20120713154519.60a686e8.akpm@linux-foundation.org>
Date: Fri, 13 Jul 2012 16:09:11 -0700
Message-ID: <CANN689HSZqpsiOAMpKe_4=TWNhv7YPkiE5pqpnq1QQKkCiHm6Q@mail.gmail.com>
Subject: Re: [PATCH v2 05/12] rbtree: performance and correctness test
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: aarcange@redhat.com, dwmw2@infradead.org, riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, axboe@kernel.dk, ebiederm@xmission.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Fri, Jul 13, 2012 at 3:45 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Fri, 13 Jul 2012 15:33:35 -0700 Michel Lespinasse <walken@google.com> wrote:
>> Ah, I did not realize we had a precedent for in-tree kernel test modules.
>
> hm, well, just because that's what we do now doesn't mean that it was a
> good idea ;) These things arrive as a result of individual developers
> doing stuff in their little directories and no particular thought was
> put into overall structure.
>
> It could be that it would be better to put all these tests into a
> central place, rather than sprinkling them around the tree.  If so,
> then your patch can lead the way, and we (ie: I) prod past and future
> developers into getting with the program.
>
> otoh, perhaps in-kernel test modules will rely on headers and constants
> which are private to the implementation directory.  So perhaps
> sprinkled-everywhere is the best approach.

I think it is at least reasonable. Where we could improve, however,
would be on the Kconfig side of things.

>> I don't think my proposal was significantly better than this
>> precedent, so I'll just adjust my patch to conform to it:
>> - move rbtree_test.c to lib/
>> - modify just lib/Makefile and lib/Kconfig.debug to get the module built.
>>
>> Will send a replacement patch for this (so you can drop that one patch
>> from the stack and replace it with)
>
> OK, you could do that too.  That way you avoid the problem and we can
> worry about it later (if ever), as a separate activity.

Going to attach as a reply to this email.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
