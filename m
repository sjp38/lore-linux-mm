Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 8971D6B007B
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 20:39:28 -0400 (EDT)
Received: by yhr47 with SMTP id 47so3884012yhr.14
        for <linux-mm@kvack.org>; Thu, 12 Jul 2012 17:39:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1342102376.28010.7.camel@twins>
References: <1341876923-12469-1-git-send-email-walken@google.com>
	<1342012996.3462.154.camel@twins>
	<20120712011208.GA1152@google.com>
	<1342102376.28010.7.camel@twins>
Date: Thu, 12 Jul 2012 17:39:27 -0700
Message-ID: <CANN689GdKaACaCcvuFym5qp=QJEMRVmK1qzmV4PpyfxLYCgk+A@mail.gmail.com>
Subject: Re: [PATCH 00/13] rbtree updates
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: aarcange@redhat.com, dwmw2@infradead.org, riel@redhat.com, daniel.santos@pobox.com, axboe@kernel.dk, ebiederm@xmission.com, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Thu, Jul 12, 2012 at 7:12 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Wed, 2012-07-11 at 18:12 -0700, Michel Lespinasse wrote:
>>
>> In __rb_erase_color(), some of the cases are more complicated than you drew however, because some node colors aren't known.
>
> Right, the wikipedia article draws them blank, I couldn't come up with a
> 3rd case, although maybe we can annotate them like (P) to mean blank..

Ah, good idea, I adopted that :)

> Yes, very nice.. someday when I'm bored I might expand the comments with
> the reason why we're doing the given operation.

There is a brief comment at the start of the loop that indicates which
rbtree invariants might be violated at that point; so someone could
deduce that we're trying to either fix these or move towards the root
until they get fixed. But yeah, this is never explicitly explained.

> Also, I was sorely tempted to rename your tmp1,tmp2 variables to sl and
> sr.

This could be done, but you'd *still* need one extra temporary, so
you'd end up with sl, sr and tmp. Which is fine, I guess, but I
preferred to have one less variable around.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
