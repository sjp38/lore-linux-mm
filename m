Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id D4927829CE
	for <linux-mm@kvack.org>; Fri, 22 May 2015 17:18:32 -0400 (EDT)
Received: by paza2 with SMTP id a2so19564826paz.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:18:32 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id mo9si5093138pbc.22.2015.05.22.14.18.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 14:18:32 -0700 (PDT)
Date: Fri, 22 May 2015 14:18:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 22/23] userfaultfd: avoid mmap_sem read recursion in
 mcopy_atomic
Message-Id: <20150522141830.f969b285ad072a23bb28f196@linux-foundation.org>
In-Reply-To: <20150522204809.GB4251@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
	<1431624680-20153-23-git-send-email-aarcange@redhat.com>
	<20150522131822.74f374dd5a75a0285577c714@linux-foundation.org>
	<20150522204809.GB4251@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>


There's a more serious failure with i386 allmodconfig:

fs/userfaultfd.c:145:2: note: in expansion of macro 'BUILD_BUG_ON'
  BUILD_BUG_ON(sizeof(struct uffd_msg) != 32);

I'm surprised the feature is even reachable on i386 builds?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
