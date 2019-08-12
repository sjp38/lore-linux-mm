Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3F52C31E40
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 22:49:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 547C820665
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 22:49:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="e92k/bnv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 547C820665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F401D6B0003; Mon, 12 Aug 2019 18:49:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EEFE06B0005; Mon, 12 Aug 2019 18:49:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB7A16B0006; Mon, 12 Aug 2019 18:49:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0124.hostedemail.com [216.40.44.124])
	by kanga.kvack.org (Postfix) with ESMTP id B43876B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 18:49:42 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 6CED12C79
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 22:49:42 +0000 (UTC)
X-FDA: 75815269404.29.deer90_1a7af7eace447
X-HE-Tag: deer90_1a7af7eace447
X-Filterd-Recvd-Size: 7011
Received: from mail-ot1-f66.google.com (mail-ot1-f66.google.com [209.85.210.66])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 22:49:41 +0000 (UTC)
Received: by mail-ot1-f66.google.com with SMTP id o101so12381650ota.8
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 15:49:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=nHhlgYEkAMLzpeQp5iTnO0Cc38tccOHo+I1ij6totIw=;
        b=e92k/bnvuAJZMf7wPi0zDqgrta8CwAOps3mGD4JUI60fT4hHB9sJp+uFferOHrL/dE
         Qkj3IBwj9c3M+Z9goPvXZ3okY116OnbfFsy262hBGLKLVRlcFMtCToIzXLkcF3oW4NEU
         K+W1kxnyrB7kVw4a6YVD369pGDT360Oq2BdtEbneY78ShmHCG+ASHvUCcJ+WxV9kMID/
         vlUqnO9TDNQj2N17N8erBgYGv4ejoo28DxbFZVZi3tIil/Rr8UFv3xFXNJ5y9lc+WESc
         fg4uhV9qoqTJH6sJrG75GadkGvncgvxVl2k44kY13A2v1MwxFmUfFqx8BQCSacrgMjAh
         n3dw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=nHhlgYEkAMLzpeQp5iTnO0Cc38tccOHo+I1ij6totIw=;
        b=Sh4aoLRJ1FXhN2RCrcW/kZA8LCpBntll2KIxooABQbvazdGTACxFoOWreYwy1Qw73J
         qFOlE74x9sYNB4IAafRYxJ4X3g1kI0MJuN5E0DeYFQOwfyFeza9O3iQcLqFXQzTLRnrk
         pNubII4KVPkWw9JHBW2mtzjNfYS9LZk/v8Kvdigpvyl1hA33SEjmmiFIR1h9xBx+2MyV
         cgcK4B6LJTYv6sAuIL+8D8gKXYpCvHDepF+9tASmzPaiyY+r6BAnh4alWs3pDqNmtfvr
         bNc8ZoVhaI4rVPv+iII5qSFlkKxgQpkOTmrX5j6pO1vAfOl66KIv3tJ3qk313Al9zxPE
         ynyA==
X-Gm-Message-State: APjAAAWVO705s/uSGMz8UWOnlCgelc8j4tMrMBX8HEgs4UaXDEl9+if1
	HSh4vIxRXdXDZpACirREq5mKdsZ56EKP41RX6K4=
X-Google-Smtp-Source: APXvYqwZ7pS16vyR1zCPDVdm0U9hbTlyCWAkwYgnJ/4qGi+bBVtiNKv9ffJ5GtcXg9KfgBsSpyc+QqxKgl44sM7rMhI=
X-Received: by 2002:a5e:8c11:: with SMTP id n17mr142032ioj.64.1565650180999;
 Mon, 12 Aug 2019 15:49:40 -0700 (PDT)
MIME-Version: 1.0
References: <20190812213158.22097.30576.stgit@localhost.localdomain>
 <20190812213324.22097.30886.stgit@localhost.localdomain> <CAPcyv4jEvPL3qQffDsJxKxkCJLo19FN=gd4+LtZ1FnARCr5wBw@mail.gmail.com>
In-Reply-To: <CAPcyv4jEvPL3qQffDsJxKxkCJLo19FN=gd4+LtZ1FnARCr5wBw@mail.gmail.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 12 Aug 2019 15:49:30 -0700
Message-ID: <CAKgT0UeHAXCM+aXL=SYXqVym=Vy3av21Vc6VY-rWQYE13-MNKg@mail.gmail.com>
Subject: Re: [PATCH v5 1/6] mm: Adjust shuffle code to allow for future coalescing
To: Dan Williams <dan.j.williams@intel.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, KVM list <kvm@vger.kernel.org>, 
	"Michael S. Tsirkin" <mst@redhat.com>, David Hildenbrand <david@redhat.com>, Dave Hansen <dave.hansen@intel.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Andrew Morton <akpm@linux-foundation.org>, virtio-dev@lists.oasis-open.org, 
	Oscar Salvador <osalvador@suse.de>, Yang Zhang <yang.zhang.wz@gmail.com>, 
	Pankaj Gupta <pagupta@redhat.com>, Rik van Riel <riel@surriel.com>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, lcapitulino@redhat.com, 
	"Wang, Wei W" <wei.w.wang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, 
	Paolo Bonzini <pbonzini@redhat.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 12, 2019 at 3:24 PM Dan Williams <dan.j.williams@intel.com> wrote:
>
> On Mon, Aug 12, 2019 at 2:33 PM Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
> >
> > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> >
> > This patch is meant to move the head/tail adding logic out of the shuffle
>
> s/This patch is meant to move/Move/

I'll update that on next submission.

> > code and into the __free_one_page function since ultimately that is where
> > it is really needed anyway. By doing this we should be able to reduce the
> > overhead
>
> Is the overhead benefit observable? I would expect the overhead of
> get_random_u64() dominates.
>
> > and can consolidate all of the list addition bits in one spot.
>
> This sounds the better argument.

Actually the overhead is the bit where we have to setup the arguments
and call the function. There is only one spot where this function is
ever called and that is in __free_one_page.

> [..]
> > diff --git a/mm/shuffle.h b/mm/shuffle.h
> > index 777a257a0d2f..add763cc0995 100644
> > --- a/mm/shuffle.h
> > +++ b/mm/shuffle.h
> > @@ -3,6 +3,7 @@
> >  #ifndef _MM_SHUFFLE_H
> >  #define _MM_SHUFFLE_H
> >  #include <linux/jump_label.h>
> > +#include <linux/random.h>
> >
> >  /*
> >   * SHUFFLE_ENABLE is called from the command line enabling path, or by
> > @@ -43,6 +44,32 @@ static inline bool is_shuffle_order(int order)
> >                 return false;
> >         return order >= SHUFFLE_ORDER;
> >  }
> > +
> > +static inline bool shuffle_add_to_tail(void)
> > +{
> > +       static u64 rand;
> > +       static u8 rand_bits;
> > +       u64 rand_old;
> > +
> > +       /*
> > +        * The lack of locking is deliberate. If 2 threads race to
> > +        * update the rand state it just adds to the entropy.
> > +        */
> > +       if (rand_bits-- == 0) {
> > +               rand_bits = 64;
> > +               rand = get_random_u64();
> > +       }
> > +
> > +       /*
> > +        * Test highest order bit while shifting our random value. This
> > +        * should result in us testing for the carry flag following the
> > +        * shift.
> > +        */
> > +       rand_old = rand;
> > +       rand <<= 1;
> > +
> > +       return rand < rand_old;
> > +}
>
> This function seems too involved to be a static inline and I believe
> each compilation unit that might call this routine gets it's own copy
> of 'rand' and 'rand_bits' when the original expectation is that they
> are global. How about leave this bit to mm/shuffle.c and rename it
> coin_flip(), or something more generic, since it does not
> 'add_to_tail'? The 'add_to_tail' action is something the caller
> decides.

The thing is there is only one caller to this function, and that is
__free_one_page. That is why I made it a static inline since that way
we can avoid having to call this as a function at all and can just
inline the code into __free_one_page.

As far as making this more generic I guess I can look into that. Maybe
I will look at trying to implement something like get_random_bool()
and then just do a macro to point to that. One other things that
occurs to me now that I am looking over the code is that I am not sure
the original or this modified version actually provide all that much
randomness if multiple threads have access to it at the same time. If
rand_bits races past the 0 you can end up getting streaks of 0s for
256+ bits.

