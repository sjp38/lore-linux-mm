Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id A5F6A6B0037
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 17:53:28 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id y10so5210929pdj.4
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 14:53:28 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id se5si17605236pbc.27.2014.09.22.14.53.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Sep 2014 14:53:27 -0700 (PDT)
Date: Mon, 22 Sep 2014 14:53:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] kvm: Faults which trigger IO release the mmap_sem
Message-Id: <20140922145325.a63c848db6ebc02b5a4e5b35@linux-foundation.org>
In-Reply-To: <54209574.6020002@redhat.com>
References: <1410811885-17267-1-git-send-email-andreslc@google.com>
	<1410976308-7683-1-git-send-email-andreslc@google.com>
	<20140918002917.GA3921@kernel>
	<20140918061326.GC30733@minantech.com>
	<20140919003207.GA4296@kernel>
	<CAJu=L5_SPcqca0sBYcCLjt4hv6RQwa+QV8Fhi6t3mxz0+X=KSA@mail.gmail.com>
	<541BC848.6080001@redhat.com>
	<CAJu=L5-B+2POA1h0P5cO2-SBDpQpHi35bvcAxWw4G+GMaQeHCw@mail.gmail.com>
	<54209574.6020002@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Andres Lagar-Cavilla <andreslc@google.com>, Wanpeng Li <wanpeng.li@linux.intel.com>, Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 22 Sep 2014 23:32:36 +0200 Paolo Bonzini <pbonzini@redhat.com> wrote:

> Il 22/09/2014 22:49, Andres Lagar-Cavilla ha scritto:
> >>> > > Paolo, should I recut including the recent Reviewed-by's?
> >> >
> >> > No, I'll add them myself.
> > Paolo, is this patch waiting for something? Is Gleb's Reviewed-by enough?
> 
> It's waiting for an Acked-by on the mm/ changes.
> 

The MM changes look good to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
