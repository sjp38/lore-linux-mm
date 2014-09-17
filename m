Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5E2486B0035
	for <linux-mm@kvack.org>; Wed, 17 Sep 2014 16:02:14 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id em10so1915351wid.6
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 13:02:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c19si211540wiv.75.2014.09.17.13.02.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Sep 2014 13:02:13 -0700 (PDT)
Message-ID: <5419E89B.7020002@redhat.com>
Date: Wed, 17 Sep 2014 22:01:31 +0200
From: Paolo Bonzini <pbonzini@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] kvm: Faults which trigger IO release the mmap_sem
References: <1410811885-17267-1-git-send-email-andreslc@google.com>	<54184078.4070505@redhat.com>	<CAJu=L5_w+u6komiZB6RE1+9H5MiL+8RJBy_GYO6CmjqkhaG5Zg@mail.gmail.com>	<54188179.7010705@redhat.com>	<CAJu=L58z-=_KkZXpEiPjDUup8GpH7079HH39csmvgUxGkvXy0A@mail.gmail.com>	<54193BB2.8010500@redhat.com> <CAJu=L5-_1ZDyhnMTFePRCyECr1rVLeMqR6dCDK1m6baR7J7gpw@mail.gmail.com>
In-Reply-To: <CAJu=L5-_1ZDyhnMTFePRCyECr1rVLeMqR6dCDK1m6baR7J7gpw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Lagar-Cavilla <andreslc@google.com>
Cc: Gleb Natapov <gleb@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Il 17/09/2014 18:58, Andres Lagar-Cavilla ha scritto:
> Understood. So in patch 1, would kvm_gup_retry be ... just a wrapper
> around gup? That looks thin to me, and the naming of the function will
> not be accurate.

Depends on how you interpret "retry" ("with retry" vs. "retry after
_fast"). :)

My point was more to make possible future bisection easier, but I'm not
going to insist.  I'll queue the patch as soon as I get the required
Acked-by.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
