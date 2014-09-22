Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f45.google.com (mail-yh0-f45.google.com [209.85.213.45])
	by kanga.kvack.org (Postfix) with ESMTP id 124C16B0035
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 17:54:46 -0400 (EDT)
Received: by mail-yh0-f45.google.com with SMTP id a41so1372719yho.4
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 14:54:45 -0700 (PDT)
Received: from mail-yh0-x229.google.com (mail-yh0-x229.google.com [2607:f8b0:4002:c01::229])
        by mx.google.com with ESMTPS id 5si7488907yhp.173.2014.09.22.14.54.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 22 Sep 2014 14:54:45 -0700 (PDT)
Received: by mail-yh0-f41.google.com with SMTP id b6so2327140yha.14
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 14:54:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5420991C.2000400@redhat.com>
References: <1411410865-3603-1-git-send-email-andreslc@google.com>
	<1411417565-15748-1-git-send-email-andreslc@google.com>
	<5420991C.2000400@redhat.com>
Date: Mon, 22 Sep 2014 14:54:45 -0700
Message-ID: <CAJu=L59=QGpWWW=ghPkFyhParXB4jMepQROiQ+5ZBh235Dmepg@mail.gmail.com>
Subject: Re: [PATCH v3] kvm: Fix page ageing bugs
From: Andres Lagar-Cavilla <andreslc@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andres Lagar-Cavilla <andreslc@gooogle.com>

On Mon, Sep 22, 2014 at 2:48 PM, Paolo Bonzini <pbonzini@redhat.com> wrote:
> Il 22/09/2014 22:26, Andres Lagar-Cavilla ha scritto:
>> +             __entry->gfn            = gfn;
>> +             __entry->hva            = ((gfn - slot->base_gfn) >>
>
> This must be <<.

Correct, thanks.

>
>> +                                         PAGE_SHIFT) + slot->userspace_addr;
>
>> +             /*
>> +              * No need for _notify because we're called within an
>> +              * mmu_notifier_invalidate_range_ {start|end} scope.
>> +              */
>
> Why "called within"?  It is try_to_unmap_cluster itself that calls
> mmu_notifier_invalidate_range_*, so "we're within an
> mmu_notifier_invalidate_range_start/end scope" sounds better, and it's
> also what you use in the commit message.

Also correct. V4...
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
