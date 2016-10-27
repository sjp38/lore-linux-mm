Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id AD63C6B0275
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 20:12:09 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id py6so11359811pab.0
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 17:12:09 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t82si5090677pgb.161.2016.10.26.17.12.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 17:12:08 -0700 (PDT)
Date: Wed, 26 Oct 2016 17:12:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: remove unnecessary __get_user_pages_unlocked()
 calls
Message-Id: <20161026171207.e76e4420dd95afcf16cc7c59@linux-foundation.org>
In-Reply-To: <20161026092548.12712-1-lstoakes@gmail.com>
References: <20161025233609.5601-1-lstoakes@gmail.com>
	<20161026092548.12712-1-lstoakes@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?UTF-8?Q?Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org



> Subject: [PATCH v2] mm: remove unnecessary __get_user_pages_unlocked() calls

The patch is rather misidentified.

>  virt/kvm/async_pf.c | 7 ++++---
>  virt/kvm/kvm_main.c | 5 ++---
>  2 files changed, 6 insertions(+), 6 deletions(-)

It's a KVM patch and should have been called "kvm: remove ...". 
Possibly the KVM maintainers will miss it for this reason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
