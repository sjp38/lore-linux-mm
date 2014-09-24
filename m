Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id EB8526B0035
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 04:28:04 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id x12so5813886wgg.32
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 01:28:04 -0700 (PDT)
Received: from mail-wg0-x22f.google.com (mail-wg0-x22f.google.com [2a00:1450:400c:c00::22f])
        by mx.google.com with ESMTPS id bl1si18407079wjb.144.2014.09.24.01.28.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 24 Sep 2014 01:28:03 -0700 (PDT)
Received: by mail-wg0-f47.google.com with SMTP id y10so5976473wgg.6
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 01:28:03 -0700 (PDT)
Message-ID: <5422808B.5070002@redhat.com>
Date: Wed, 24 Sep 2014 10:27:55 +0200
From: Paolo Bonzini <pbonzini@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4] kvm: Fix page ageing bugs
References: <1411410865-3603-1-git-send-email-andreslc@google.com> <1411422882-16245-1-git-send-email-andreslc@google.com> <20140924022729.GA2889@kernel> <54226CEB.9080504@redhat.com> <542270BA.4090708@gmail.com>
In-Reply-To: <542270BA.4090708@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <kernellwp@gmail.com>, Wanpeng Li <wanpeng.li@linux.intel.com>, Andres Lagar-Cavilla <andreslc@google.com>
Cc: Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Il 24/09/2014 09:20, Wanpeng Li ha scritto:
> 
> This trace point still dup duplicated message for the same gfn in the
> for loop.

Yes, but the gfn argument lets you take it out again.

Note that having the duplicated trace would make sense if you included
the accessed bit for each spte, instead of just the "young" variable.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
