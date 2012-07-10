Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id BF9756B0071
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 19:12:55 -0400 (EDT)
Received: by ggm4 with SMTP id 4so710832ggm.14
        for <linux-mm@kvack.org>; Tue, 10 Jul 2012 16:12:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <op.wg8ciikk3l0zgt@mpn-glaptop>
References: <1341876923-12469-1-git-send-email-walken@google.com>
	<1341876923-12469-5-git-send-email-walken@google.com>
	<op.wg8ciikk3l0zgt@mpn-glaptop>
Date: Tue, 10 Jul 2012 16:12:54 -0700
Message-ID: <CANN689E8_5YPCu9WMfgSAbBFkQYhfQkoYejdGRd-NPSiFhVuTg@mail.gmail.com>
Subject: Re: [PATCH 04/13] rbtree: move some implementation details from
 rbtree.h to rbtree.c
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: aarcange@redhat.com, dwmw2@infradead.org, riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, axboe@kernel.dk, ebiederm@xmission.com, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Tue, Jul 10, 2012 at 5:19 AM, Michal Nazarewicz <mina86@mina86.com> wrote:
> On Tue, 10 Jul 2012 01:35:14 +0200, Michel Lespinasse <walken@google.com> wrote:
>> +#define        RB_RED          0
>> +#define        RB_BLACK        1
>
> Interestingly, those are almost never used. RB_BLACK is used only once.
> Should we get rid of those instead?  Or change the code (like rb_is_red())
> to use them?

I'm actually making heavier use of RB_RED / RB_BLACK later on in the patch set.
But agree, rb_is_red() / rb_is_black() could use these too.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
