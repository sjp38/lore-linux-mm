Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id DB73E6B0005
	for <linux-mm@kvack.org>; Tue, 24 May 2016 16:55:54 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id s130so14753741lfs.2
        for <linux-mm@kvack.org>; Tue, 24 May 2016 13:55:54 -0700 (PDT)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id z71si7275006wmh.41.2016.05.24.13.55.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 May 2016 13:55:53 -0700 (PDT)
Received: by mail-wm0-x234.google.com with SMTP id n129so39030563wmn.1
        for <linux-mm@kvack.org>; Tue, 24 May 2016 13:55:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160524224551.9a8aec90836b3866c3e5a232@gmail.com>
References: <20160524001405.3e6abd1d5a63a871cc366cff@gmail.com>
 <20160524001629.7a9f0c5ce8427d0ad5e951fd@gmail.com> <CAGXu5j+RQnSu2GgiRFP7UhDpLiuP=becZ-GXPoVRfXk6_wh3Gg@mail.gmail.com>
 <20160524224551.9a8aec90836b3866c3e5a232@gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 24 May 2016 13:55:51 -0700
Message-ID: <CAGXu5jJ+e0CX3QBm-XWYJ6ViCuX-Pcbvm-he7FBqYJBScw1kPA@mail.gmail.com>
Subject: Re: [PATCH v1 2/3] Mark functions with the latent_entropy attribute
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Emese Revfy <re.emese@gmail.com>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Michal Marek <mmarek@suse.com>, LKML <linux-kernel@vger.kernel.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, linux-kbuild <linux-kbuild@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>, Al Viro <viro@zeniv.linux.org.uk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, bart.vanassche@sandisk.com, "David S. Miller" <davem@davemloft.net>

On Tue, May 24, 2016 at 1:45 PM, Emese Revfy <re.emese@gmail.com> wrote:
> On Tue, 24 May 2016 10:16:09 -0700
> Kees Cook <keescook@chromium.org> wrote:
>
>> On Mon, May 23, 2016 at 3:16 PM, Emese Revfy <re.emese@gmail.com> wrote:
>> > +#ifdef CONFIG_MEMORY_HOTPLUG
>> > +#define add_meminit_latent_entropy
>> > +#else
>> > +#define add_meminit_latent_entropy __latent_entropy
>> > +#endif
>> > +
>> >  /* These are for everybody (although not all archs will actually
>> >     discard it in modules) */
>> > -#define __init         __section(.init.text) __cold notrace
>> > +#define __init         __section(.init.text) __cold notrace __latent_entropy
>> >  #define __initdata     __section(.init.data)
>> >  #define __initconst    __constsection(.init.rodata)
>> >  #define __exitdata     __section(.exit.data)
>> > @@ -92,7 +98,7 @@
>> >  #define __exit          __section(.exit.text) __exitused __cold notrace
>> >
>> >  /* Used for MEMORY_HOTPLUG */
>> > -#define __meminit        __section(.meminit.text) __cold notrace
>> > +#define __meminit        __section(.meminit.text) __cold notrace add_meminit_latent_entropy
>> >  #define __meminitdata    __section(.meminit.data)
>> >  #define __meminitconst   __constsection(.meminit.rodata)
>> >  #define __memexit        __section(.memexit.text) __exitused __cold notrace
>>
>> I was confused by these defines. :) Maybe "add_meminit_latent_entropy"
>> should be named "__memory_hotplug_only_latent_entropy" or something
>> like that?
>
> I think the plugin doesn't cause a significant slowdown when CONFIG_MEMORY_HOTPLUG is enabled so I would rather always add the __latent_entropy attribute to __meminit.

That seems fine to me. :)

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
