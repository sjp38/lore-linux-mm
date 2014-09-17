Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 356966B0035
	for <linux-mm@kvack.org>; Wed, 17 Sep 2014 07:27:55 -0400 (EDT)
Received: by mail-qg0-f53.google.com with SMTP id q108so1594793qgd.26
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 04:27:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u6si22220706qap.12.2014.09.17.04.27.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Sep 2014 04:27:54 -0700 (PDT)
Date: Wed, 17 Sep 2014 13:27:14 +0200
From: Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>
Subject: Re: [PATCH] kvm: Faults which trigger IO release the mmap_sem
Message-ID: <20140917112713.GB1273@potion.brq.redhat.com>
References: <1410811885-17267-1-git-send-email-andreslc@google.com>
 <20140917102635.GA30733@minantech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140917102635.GA30733@minantech.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gleb Natapov <gleb@kernel.org>
Cc: Andres Lagar-Cavilla <andreslc@google.com>, Gleb Natapov <gleb@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

2014-09-17 13:26+0300, Gleb Natapov:
> For async_pf_execute() you do not need to even retry. Next guest's page fault
> will retry it for you.

Wouldn't that be a waste of vmentries?

The guest might be able to handle interrupts while we are waiting, so if
we used async-io-done notifier, this could work without CPU spinning.
(Probably with added latency.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
