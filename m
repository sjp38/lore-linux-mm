Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 5FD836B0069
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 17:34:28 -0400 (EDT)
Received: by ggnf4 with SMTP id f4so925028ggn.14
        for <linux-mm@kvack.org>; Mon, 06 Aug 2012 14:34:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1344263140.27828.59.camel@twins>
References: <1343946858-8170-1-git-send-email-walken@google.com>
	<1343946858-8170-9-git-send-email-walken@google.com>
	<1344263140.27828.59.camel@twins>
Date: Mon, 6 Aug 2012 14:34:26 -0700
Message-ID: <CANN689GbB5Rj3FmgP_RWj5EJVxJKBZS1WavZCKg0tuYR4vMZpg@mail.gmail.com>
Subject: Re: [PATCH v2 8/9] rbtree: faster augmented rbtree manipulation
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: riel@redhat.com, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Mon, Aug 6, 2012 at 7:25 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Thu, 2012-08-02 at 15:34 -0700, Michel Lespinasse wrote:
>> +struct rb_augment_callbacks {
>> +       void (*propagate)(struct rb_node *node, struct rb_node *stop);
>> +       void (*copy)(struct rb_node *old, struct rb_node *new);
>> +       void (*rotate)(struct rb_node *old, struct rb_node *new);
>> +};
>
> Should we make that const pointers? Daniel?

I don't think it would hurt, but note that each function taking this
as an argument takes it as a const struct rb_augment_callbacks *, so I
doubt the extra consts would help either.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
