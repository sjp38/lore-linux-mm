Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 47BCF6B0116
	for <linux-mm@kvack.org>; Wed, 20 May 2015 09:23:47 -0400 (EDT)
Received: by qcir1 with SMTP id r1so22920398qci.3
        for <linux-mm@kvack.org>; Wed, 20 May 2015 06:23:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 199si2723625qhe.36.2015.05.20.06.23.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 May 2015 06:23:46 -0700 (PDT)
Date: Wed, 20 May 2015 15:23:19 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00/23] userfaultfd v4
Message-ID: <20150520132319.GN19097@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
 <20150519143801.8ba477c3813e93a2637c19cf@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150519143801.8ba477c3813e93a2637c19cf@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

Hi Andrew,

On Tue, May 19, 2015 at 02:38:01PM -0700, Andrew Morton wrote:
> On Thu, 14 May 2015 19:30:57 +0200 Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
> > This is the latest userfaultfd patchset against mm-v4.1-rc3
> > 2015-05-14-10:04.
> 
> It would be useful to have some userfaultfd testcases in
> tools/testing/selftests/.  Partly as an aid to arch maintainers when
> enabling this.  And also as a standalone thing to give people a
> practical way of exercising this interface.

Agreed.

I was also thinking about writing a trinity module for it, I wrote it
for an older version but it was much easier to do that back then
before we had ioctls, now it's more tricky because the ioctls requires
the fd open first etc... it's not enough to just call a syscall with a
flood of supervised-random params anymore.

> What are your thoughts on enabling userfaultfd for other architectures,
> btw?  Are there good use cases, are people working on it, etc?

powerpc should be enabled and functional already. There's not much
arch dependent code in it, so in theory if the postcopy live migration
patchset is applied to qemu, it should work on powerpc out of the
box. Nobody tested it yet but I don't expect trouble on the kernel side.

Adding support for all other archs is just a few liner patch that
defines the syscall number. I didn't do that out of tree because every
time a new syscall materialized I would get more rejects during
rebase.

> Also, I assume a manpage is in the works?  Sooner rather than later
> would be good - Michael's review of proposed kernel interfaces has
> often been valuable.

Yes, the manpage was certainly planned. It would require updates as we
keep adding features (like the wrprotect tracking, the non-cooperative
usage, and extending the availability of the ioctls to tmpfs). We can
definitely write a manpage with the current features.

Ok, so I'll continue working on the testcase and on the manpage.

Thanks!!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
