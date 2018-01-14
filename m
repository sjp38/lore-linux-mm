Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 44B276B0038
	for <linux-mm@kvack.org>; Sun, 14 Jan 2018 15:57:53 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id q28so7962848uaa.6
        for <linux-mm@kvack.org>; Sun, 14 Jan 2018 12:57:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j193sor3025925vkf.110.2018.01.14.12.57.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 14 Jan 2018 12:57:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1801111101420.6443@nuc-kabylake>
References: <1515636190-24061-1-git-send-email-keescook@chromium.org>
 <1515636190-24061-3-git-send-email-keescook@chromium.org> <alpine.DEB.2.20.1801111101420.6443@nuc-kabylake>
From: Kees Cook <keescook@chromium.org>
Date: Sun, 14 Jan 2018 12:57:50 -0800
Message-ID: <CAGXu5jL_FbA5FqhFG4OUQ0GaebU2HMmaE4av1DqtCPuqLCpayA@mail.gmail.com>
Subject: Re: [PATCH 02/38] usercopy: Enhance and rename report_usercopy()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Windsor <dave@nullcore.net>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Network Development <netdev@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, kernel-hardening@lists.openwall.com

On Thu, Jan 11, 2018 at 9:06 AM, Christopher Lameter <cl@linux.com> wrote:
> On Wed, 10 Jan 2018, Kees Cook wrote:
>
>> diff --git a/mm/slab.h b/mm/slab.h
>> index ad657ffa44e5..7d29e69ac310 100644
>> --- a/mm/slab.h
>> +++ b/mm/slab.h
>> @@ -526,4 +526,10 @@ static inline int cache_random_seq_create(struct kmem_cache *cachep,
>>  static inline void cache_random_seq_destroy(struct kmem_cache *cachep) { }
>>  #endif /* CONFIG_SLAB_FREELIST_RANDOM */
>>
>> +#ifdef CONFIG_HARDENED_USERCOPY
>> +void __noreturn usercopy_abort(const char *name, const char *detail,
>> +                            bool to_user, unsigned long offset,
>> +                            unsigned long len);
>> +#endif
>> +
>>  #endif /* MM_SLAB_H */
>
> This code has nothing to do with slab allocation. Move it into
> include/linux/uaccess.h where the other user space access definitions are?

Since it was only the mm/sl*b.c files using it, it seemed like the
right place, but it's a reasonable point. I've moved it now.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
