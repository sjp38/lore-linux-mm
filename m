Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f71.google.com (mail-qg0-f71.google.com [209.85.192.71])
	by kanga.kvack.org (Postfix) with ESMTP id 73A396B0253
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 12:03:20 -0400 (EDT)
Received: by mail-qg0-f71.google.com with SMTP id e35so14652637qge.0
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 09:03:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m131si2729578qke.164.2016.04.27.09.03.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 09:03:19 -0700 (PDT)
Date: Wed, 27 Apr 2016 18:03:17 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/1] mm: thp: kvm: fix memory corruption in KVM with THP
 enabled
Message-ID: <20160427160317.GC11700@redhat.com>
References: <1461758686-27157-1-git-send-email-aarcange@redhat.com>
 <20160427135030.GB22035@node.shutemov.name>
 <20160427145957.GA9217@redhat.com>
 <20160427151834.GC22035@node.shutemov.name>
 <20160427155730.GB11700@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160427155730.GB11700@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "Li, Liang Z" <liang.z.li@intel.com>, Amit Shah <amit.shah@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>

On Wed, Apr 27, 2016 at 05:57:30PM +0200, Andrea Arcangeli wrote:
> couldn't do a fix as cleaner as this one for 4.6.

ehm "cleaner then"

If you've suggestions for a better name than PageTransCompoundMap I
can respin a new patch though, I considered "CanMap" but I opted for
the short version.

Also I'm not really sure moving transparent_hugepage_adjust will make
much sense. I mentioned it because Andres in another thread said it
was suggested but the real common code knowledge is about
PageTransCompoundMap only, all sort of !mmu_gfn_lpage_is_disallowed
for dirty logging at 4k shadow granularity is KVM internal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
