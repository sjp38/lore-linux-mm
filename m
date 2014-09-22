Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id F181F6B0035
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 17:32:49 -0400 (EDT)
Received: by mail-qc0-f172.google.com with SMTP id c9so884386qcz.3
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 14:32:49 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f33si10450406qgd.22.2014.09.22.14.32.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Sep 2014 14:32:49 -0700 (PDT)
Message-ID: <54209574.6020002@redhat.com>
Date: Mon, 22 Sep 2014 23:32:36 +0200
From: Paolo Bonzini <pbonzini@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] kvm: Faults which trigger IO release the mmap_sem
References: <1410811885-17267-1-git-send-email-andreslc@google.com>	<1410976308-7683-1-git-send-email-andreslc@google.com>	<20140918002917.GA3921@kernel>	<20140918061326.GC30733@minantech.com>	<20140919003207.GA4296@kernel>	<CAJu=L5_SPcqca0sBYcCLjt4hv6RQwa+QV8Fhi6t3mxz0+X=KSA@mail.gmail.com>	<541BC848.6080001@redhat.com> <CAJu=L5-B+2POA1h0P5cO2-SBDpQpHi35bvcAxWw4G+GMaQeHCw@mail.gmail.com>
In-Reply-To: <CAJu=L5-B+2POA1h0P5cO2-SBDpQpHi35bvcAxWw4G+GMaQeHCw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Lagar-Cavilla <andreslc@google.com>
Cc: Wanpeng Li <wanpeng.li@linux.intel.com>, Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Il 22/09/2014 22:49, Andres Lagar-Cavilla ha scritto:
>>> > > Paolo, should I recut including the recent Reviewed-by's?
>> >
>> > No, I'll add them myself.
> Paolo, is this patch waiting for something? Is Gleb's Reviewed-by enough?

It's waiting for an Acked-by on the mm/ changes.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
