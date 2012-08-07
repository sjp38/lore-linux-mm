Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 47D0F6B0044
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 20:04:20 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so1385305ghr.14
        for <linux-mm@kvack.org>; Mon, 06 Aug 2012 17:04:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1344262930.27828.57.camel@twins>
References: <1343946858-8170-1-git-send-email-walken@google.com>
	<1343946858-8170-4-git-send-email-walken@google.com>
	<1344262930.27828.57.camel@twins>
Date: Mon, 6 Aug 2012 17:04:18 -0700
Message-ID: <CANN689GZQ4pYuqzB9ZQ0QBatvsDgj60_ciG5MBHqsKdb5CYtyQ@mail.gmail.com>
Subject: Re: [PATCH v2 3/9] rbtree: add __rb_change_child() helper function
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: riel@redhat.com, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Mon, Aug 6, 2012 at 7:22 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Thu, 2012-08-02 at 15:34 -0700, Michel Lespinasse wrote:
>> +static inline void
>
> I would make that __always_inline, just to make sure GCC doesn't go
> creative on us.

How strongly do you care ? I'm not sure it makes sense to change it
unless we also change every other inline function in that file. I'd
rather not do that until we hear of gcc actually breaking things.

(BTW, did you know that sometimes gcc generates different code when
you change from inline to always_inline, even though things were
already inlined before ? I really hate dealing with gcc crap like
that, makes me want to forget about inline functions and just do it
all with preprocessor abuse...)

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
