Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 1CC736B0035
	for <linux-mm@kvack.org>; Fri, 19 Sep 2014 02:08:16 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id hi2so1390265wib.17
        for <linux-mm@kvack.org>; Thu, 18 Sep 2014 23:08:15 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id yw4si1012408wjc.94.2014.09.18.23.08.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 18 Sep 2014 23:08:14 -0700 (PDT)
Received: by mail-wi0-f182.google.com with SMTP id hi2so1389491wib.3
        for <linux-mm@kvack.org>; Thu, 18 Sep 2014 23:08:14 -0700 (PDT)
Message-ID: <541BC848.6080001@redhat.com>
Date: Fri, 19 Sep 2014 08:08:08 +0200
From: Paolo Bonzini <pbonzini@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] kvm: Faults which trigger IO release the mmap_sem
References: <1410811885-17267-1-git-send-email-andreslc@google.com>	<1410976308-7683-1-git-send-email-andreslc@google.com>	<20140918002917.GA3921@kernel>	<20140918061326.GC30733@minantech.com>	<20140919003207.GA4296@kernel> <CAJu=L5_SPcqca0sBYcCLjt4hv6RQwa+QV8Fhi6t3mxz0+X=KSA@mail.gmail.com>
In-Reply-To: <CAJu=L5_SPcqca0sBYcCLjt4hv6RQwa+QV8Fhi6t3mxz0+X=KSA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Lagar-Cavilla <andreslc@google.com>, Wanpeng Li <wanpeng.li@linux.intel.com>
Cc: Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Il 19/09/2014 05:58, Andres Lagar-Cavilla ha scritto:
> Paolo, should I recut including the recent Reviewed-by's?

No, I'll add them myself.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
