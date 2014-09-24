Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id 35CF06B0037
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 13:17:23 -0400 (EDT)
Received: by mail-yk0-f181.google.com with SMTP id 200so2863500ykr.40
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 10:17:22 -0700 (PDT)
Received: from mail-yk0-x235.google.com (mail-yk0-x235.google.com [2607:f8b0:4002:c07::235])
        by mx.google.com with ESMTPS id f1si12286176yhd.49.2014.09.24.10.17.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 24 Sep 2014 10:17:22 -0700 (PDT)
Received: by mail-yk0-f181.google.com with SMTP id 200so2863495ykr.40
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 10:17:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5422808B.5070002@redhat.com>
References: <1411410865-3603-1-git-send-email-andreslc@google.com>
	<1411422882-16245-1-git-send-email-andreslc@google.com>
	<20140924022729.GA2889@kernel>
	<54226CEB.9080504@redhat.com>
	<542270BA.4090708@gmail.com>
	<5422808B.5070002@redhat.com>
Date: Wed, 24 Sep 2014 10:17:22 -0700
Message-ID: <CAJu=L59r-9GjZBmbQwWzJwnJMMJ5o-vWPXgA1Rv9bAwf1zywCw@mail.gmail.com>
Subject: Re: [PATCH v4] kvm: Fix page ageing bugs
From: Andres Lagar-Cavilla <andreslc@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Wanpeng Li <kernellwp@gmail.com>, Wanpeng Li <wanpeng.li@linux.intel.com>, Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Sep 24, 2014 at 1:27 AM, Paolo Bonzini <pbonzini@redhat.com> wrote:
> Il 24/09/2014 09:20, Wanpeng Li ha scritto:
>>
>> This trace point still dup duplicated message for the same gfn in the
>> for loop.
>
> Yes, but the gfn argument lets you take it out again.
>
> Note that having the duplicated trace would make sense if you included
> the accessed bit for each spte, instead of just the "young" variable.

FWIW the new arrangement in kvm.git/queue LGTM

Thanks
Andres

>
> Paolo



-- 
Andres Lagar-Cavilla | Google Kernel Team | andreslc@google.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
