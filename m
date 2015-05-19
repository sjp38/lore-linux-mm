Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 4F5CC6B00E6
	for <linux-mm@kvack.org>; Tue, 19 May 2015 17:38:04 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so41654496pdb.0
        for <linux-mm@kvack.org>; Tue, 19 May 2015 14:38:04 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d4si23255124pdj.10.2015.05.19.14.38.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 May 2015 14:38:03 -0700 (PDT)
Date: Tue, 19 May 2015 14:38:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/23] userfaultfd v4
Message-Id: <20150519143801.8ba477c3813e93a2637c19cf@linux-foundation.org>
In-Reply-To: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

On Thu, 14 May 2015 19:30:57 +0200 Andrea Arcangeli <aarcange@redhat.com> wrote:

> This is the latest userfaultfd patchset against mm-v4.1-rc3
> 2015-05-14-10:04.

It would be useful to have some userfaultfd testcases in
tools/testing/selftests/.  Partly as an aid to arch maintainers when
enabling this.  And also as a standalone thing to give people a
practical way of exercising this interface.

What are your thoughts on enabling userfaultfd for other architectures,
btw?  Are there good use cases, are people working on it, etc?


Also, I assume a manpage is in the works?  Sooner rather than later
would be good - Michael's review of proposed kernel interfaces has
often been valuable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
