Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id A2F186B0069
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 02:14:52 -0400 (EDT)
Received: by ggm4 with SMTP id 4so979042ggm.14
        for <linux-mm@kvack.org>; Tue, 10 Jul 2012 23:14:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <op.wg8cv6x53l0zgt@mpn-glaptop>
References: <1341876923-12469-1-git-send-email-walken@google.com>
	<1341876923-12469-6-git-send-email-walken@google.com>
	<op.wg8cv6x53l0zgt@mpn-glaptop>
Date: Tue, 10 Jul 2012 23:14:51 -0700
Message-ID: <CANN689EEHe+_W=pnnvf1u+BxpvY+BK6bLNZ-0Y-eoKNS=9L+rg@mail.gmail.com>
Subject: Re: [PATCH 05/13] rbtree: performance and correctness test
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: aarcange@redhat.com, dwmw2@infradead.org, riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, axboe@kernel.dk, ebiederm@xmission.com, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Tue, Jul 10, 2012 at 5:27 AM, Michal Nazarewicz <mina86@mina86.com> wrote:
> On Tue, 10 Jul 2012 01:35:15 +0200, Michel Lespinasse <walken@google.com> wrote:
>> +       u32 prev_key = 0;
>> +
>> +       for (rb = rb_first(&root); rb; rb = rb_next(rb)) {
>> +               struct test_node *node = rb_entry(rb, struct test_node,
>> rb);
>> +               WARN_ON_ONCE(node->key < prev_key);
>
> What if for some reason we generate node with key equal zero or two keys
> with the same value?  It may not be the case for current code, but someone
> might change it in the future.  I think <= is safer here.

No, it's not illegal for two nodes to have the same key; the second
one to be inserted will just get placed after the first one. The
rbtree library doesn't care either way as it's not even aware of the
key values :)

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
