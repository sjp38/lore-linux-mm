Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 1BFBC6B0071
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 19:18:41 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so703484ghr.14
        for <linux-mm@kvack.org>; Tue, 10 Jul 2012 16:18:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <op.wg8cv6x53l0zgt@mpn-glaptop>
References: <1341876923-12469-1-git-send-email-walken@google.com>
	<1341876923-12469-6-git-send-email-walken@google.com>
	<op.wg8cv6x53l0zgt@mpn-glaptop>
Date: Tue, 10 Jul 2012 16:18:39 -0700
Message-ID: <CANN689EfR=aSiwq+7GY1nh4-CkoPSPVx=xycoRAjLPTHAcm5_A@mail.gmail.com>
Subject: Re: [PATCH 05/13] rbtree: performance and correctness test
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: aarcange@redhat.com, dwmw2@infradead.org, riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, axboe@kernel.dk, ebiederm@xmission.com, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Tue, Jul 10, 2012 at 5:27 AM, Michal Nazarewicz <mina86@mina86.com> wrote:
> On Tue, 10 Jul 2012 01:35:15 +0200, Michel Lespinasse <walken@google.com> wrote:
>> +       for (i = 0; i < CHECK_LOOPS; i++) {
>> +               init();
>
> Is this init() needed?

So, the reasoning here is that we first have timed loops, where we
don't init between every iteration because it's not needed. Then we
have checked loops, where we init nodes between every iteration so
that they'll have new contents, and then check the rbtree invariants
after each insertion or erase. The init isn't required in the checked
loop either, but it should improve the test coverage a little. It'd be
pointless to run the checked loop more than once if we didn't init...

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
