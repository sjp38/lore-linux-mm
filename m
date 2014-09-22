Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f44.google.com (mail-yh0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id CF00C6B0035
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 16:49:40 -0400 (EDT)
Received: by mail-yh0-f44.google.com with SMTP id i57so645106yha.17
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 13:49:40 -0700 (PDT)
Received: from mail-yh0-x235.google.com (mail-yh0-x235.google.com [2607:f8b0:4002:c01::235])
        by mx.google.com with ESMTPS id h68si7453386yhb.64.2014.09.22.13.49.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 22 Sep 2014 13:49:40 -0700 (PDT)
Received: by mail-yh0-f53.google.com with SMTP id f73so2268245yha.40
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 13:49:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <541BC848.6080001@redhat.com>
References: <1410811885-17267-1-git-send-email-andreslc@google.com>
	<1410976308-7683-1-git-send-email-andreslc@google.com>
	<20140918002917.GA3921@kernel>
	<20140918061326.GC30733@minantech.com>
	<20140919003207.GA4296@kernel>
	<CAJu=L5_SPcqca0sBYcCLjt4hv6RQwa+QV8Fhi6t3mxz0+X=KSA@mail.gmail.com>
	<541BC848.6080001@redhat.com>
Date: Mon, 22 Sep 2014 13:49:39 -0700
Message-ID: <CAJu=L5-B+2POA1h0P5cO2-SBDpQpHi35bvcAxWw4G+GMaQeHCw@mail.gmail.com>
Subject: Re: [PATCH v2] kvm: Faults which trigger IO release the mmap_sem
From: Andres Lagar-Cavilla <andreslc@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Wanpeng Li <wanpeng.li@linux.intel.com>, Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Sep 18, 2014 at 11:08 PM, Paolo Bonzini <pbonzini@redhat.com> wrote:
>
> Il 19/09/2014 05:58, Andres Lagar-Cavilla ha scritto:
> > Paolo, should I recut including the recent Reviewed-by's?
>
> No, I'll add them myself.

Paolo, is this patch waiting for something? Is Gleb's Reviewed-by enough?

Thanks much
Andres

>
>
> Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
