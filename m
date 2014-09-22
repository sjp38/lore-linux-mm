Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2ADF06B0035
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 17:53:28 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id fb4so3598196wid.0
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 14:53:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v19si10712wij.81.2014.09.22.14.53.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Sep 2014 14:53:26 -0700 (PDT)
Message-ID: <5420991C.2000400@redhat.com>
Date: Mon, 22 Sep 2014 23:48:12 +0200
From: Paolo Bonzini <pbonzini@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] kvm: Fix page ageing bugs
References: <1411410865-3603-1-git-send-email-andreslc@google.com> <1411417565-15748-1-git-send-email-andreslc@google.com>
In-Reply-To: <1411417565-15748-1-git-send-email-andreslc@google.com>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Lagar-Cavilla <andreslc@google.com>, Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andres Lagar-Cavilla <andreslc@gooogle.com>

Il 22/09/2014 22:26, Andres Lagar-Cavilla ha scritto:
> +		__entry->gfn		= gfn;
> +		__entry->hva		= ((gfn - slot->base_gfn) >>

This must be <<.

> +					    PAGE_SHIFT) + slot->userspace_addr;

> +		/*
> +		 * No need for _notify because we're called within an
> +		 * mmu_notifier_invalidate_range_ {start|end} scope.
> +		 */

Why "called within"?  It is try_to_unmap_cluster itself that calls
mmu_notifier_invalidate_range_*, so "we're within an
mmu_notifier_invalidate_range_start/end scope" sounds better, and it's
also what you use in the commit message.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
