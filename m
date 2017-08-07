Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id CBDE96B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 15:34:29 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id v68so1026925oia.14
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 12:34:29 -0700 (PDT)
Received: from mail-it0-x235.google.com (mail-it0-x235.google.com. [2607:f8b0:4001:c0b::235])
        by mx.google.com with ESMTPS id q206si5195803oih.53.2017.08.07.12.34.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 12:34:29 -0700 (PDT)
Received: by mail-it0-x235.google.com with SMTP id 76so7208043ith.0
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 12:34:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN=P9pg25a80so+RFxpUkm1=JAVtOj_T6CaO3GSZc2+A-PPk6A@mail.gmail.com>
References: <CACT4Y+bLGEC=14CUJpkMhw0toSxvbyqKj49kqqW+gCLLBDFu4A@mail.gmail.com>
 <CAGXu5jJhFt8JNFRnB-oiGjNy=Auo4bGx=i=DDtCa__20acANBQ@mail.gmail.com>
 <CAN=P9pj_jbTgGoiECmu-b=s+NOL6uTkPbXDueXLhs8C6PVbLHg@mail.gmail.com>
 <CAGXu5jLRG6Xee-dJGPwmbfcVFLuTP9+5mexJyvZamQQdSaHNtA@mail.gmail.com>
 <1502131739.1803.12.camel@gmail.com> <CAGXu5jKj0M55wK=0WE_uKJpiJ031J5jPVAZR-VA7_O2qJUi=BQ@mail.gmail.com>
 <CAN=P9pj0TSbwTogLAJrm=yszq+86X0EmXNK-0Oq9f7wQCkQRjA@mail.gmail.com>
 <CAGXu5jJOOvv=zgSWnKJOae0edKG8MUV1pto1ipijPiRsOdKr+Q@mail.gmail.com>
 <CAN=P9pgcuXUk=+TvFC83UT7xT66=X2ouvEEWxzVVeM2mC=Tk=g@mail.gmail.com>
 <CAGXu5jJNW5PYacSNrGGnyAxnv4cRuhbo+P9myHP9kcV7hMzhkA@mail.gmail.com>
 <CAN=P9ph4f3S3SwSpmpApKKnQ=ce6JXLcpqHG+oJ8EpmSiur0AA@mail.gmail.com>
 <CAGXu5j+x=vFrd7Owu=CgQcF7YtFAgPxUVo6G=Jzk6fo6mOQZqg@mail.gmail.com> <CAN=P9pg25a80so+RFxpUkm1=JAVtOj_T6CaO3GSZc2+A-PPk6A@mail.gmail.com>
From: Kees Cook <keescook@google.com>
Date: Mon, 7 Aug 2017 12:34:27 -0700
Message-ID: <CAGXu5jKD0Z=BKxKLDtjKq6sLgoa36bJZmc88k4QRPOHyRQp3BQ@mail.gmail.com>
Subject: Re: binfmt_elf: use ELF_ET_DYN_BASE only for PIE breaks asan
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kostya Serebryany <kcc@google.com>
Cc: Daniel Micay <danielmicay@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Reid Kleckner <rnk@google.com>, Peter Collingbourne <pcc@google.com>, Evgeniy Stepanov <eugenis@google.com>

(To be clear, this subthread is for dealing with _future_ changes; I'm
already preparing the revert, which is in the other subthread.)

On Mon, Aug 7, 2017 at 12:26 PM, Kostya Serebryany <kcc@google.com> wrote:
> Oh, a launcher (e.g. just using setarch) would be a huge pain to deploy.

Would loading the executable into the mmap region work? We could find
a way to mark executables that want this treatment.

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
