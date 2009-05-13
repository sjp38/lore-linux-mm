Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4BD5D6B013E
	for <linux-mm@kvack.org>; Wed, 13 May 2009 19:25:04 -0400 (EDT)
Date: Wed, 13 May 2009 16:25:20 -0700
From: Chris Wright <chrisw@redhat.com>
Subject: Re: [PATCH 5/5] add ksm kernel shared memory driver.
Message-ID: <20090513232520.GN12533@x200.localdomain>
References: <1240191366-10029-1-git-send-email-ieidus@redhat.com> <1240191366-10029-2-git-send-email-ieidus@redhat.com> <1240191366-10029-3-git-send-email-ieidus@redhat.com> <1240191366-10029-4-git-send-email-ieidus@redhat.com> <1240191366-10029-5-git-send-email-ieidus@redhat.com> <1240191366-10029-6-git-send-email-ieidus@redhat.com> <20090513161739.d801ab67.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090513161739.d801ab67.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, mtosatti@redhat.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

* Andrew Morton (akpm@linux-foundation.org) wrote:
> Breaks ppc64 allmodcofnig because that architecture doesn't export its
> copy_user_page() to modules.

Things like this and updating to use madvise() I think all point towards
s/tristate/bool/.  I don't think CONFIG_KSM=M has huge benefit.

thanks,
-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
