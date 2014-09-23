Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id F0C226B0038
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 13:10:38 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id z12so981365wgg.27
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 10:10:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d6si3325232wix.107.2014.09.23.10.10.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Sep 2014 10:10:37 -0700 (PDT)
Message-ID: <5421A851.70403@redhat.com>
Date: Tue, 23 Sep 2014 19:05:21 +0200
From: Paolo Bonzini <pbonzini@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4] kvm: Fix page ageing bugs
References: <1411410865-3603-1-git-send-email-andreslc@google.com>	<1411422882-16245-1-git-send-email-andreslc@google.com>	<542125F1.3080607@redhat.com> <CAJu=L58L4XrACYieQuM412TJuJoD+QYBb=qOcN1MtwdVAPzn2Q@mail.gmail.com>
In-Reply-To: <CAJu=L58L4XrACYieQuM412TJuJoD+QYBb=qOcN1MtwdVAPzn2Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Lagar-Cavilla <andreslc@google.com>
Cc: Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andres Lagar-Cavilla <andreslc@gooogle.com>

Il 23/09/2014 19:04, Andres Lagar-Cavilla ha scritto:
> I'm not sure. The addition is not always by PAGE_SIZE, since it
> depends on the current level we are iterating at in the outer
> kvm_handle_hva_range(). IOW, could be PMD_SIZE or even PUD_SIZE, and
> is_large_pte() enough to tell?
> 
> This is probably worth a general fix, I can see all the callbacks
> benefiting from knowing the gfn (passed down by
> kvm_handle_hva_range()) without any additional computation, and adding
> that to a tracing call if they don't already.
> 
> Even passing the level down to the callback would help by cutting down
> to one arithmetic op (subtract rmapp from slot rmap base pointer for
> that level)

You're right.  Let's apply this patch and work on that as a follow-up.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
