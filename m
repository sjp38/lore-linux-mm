Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 922AF5F0001
	for <linux-mm@kvack.org>; Sat, 18 Apr 2009 10:57:26 -0400 (EDT)
Date: Sat, 18 Apr 2009 16:58:06 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 4/4] add ksm kernel shared memory driver.
Message-ID: <20090418145806.GA15228@random.random>
References: <1239249521-5013-1-git-send-email-ieidus@redhat.com> <1239249521-5013-2-git-send-email-ieidus@redhat.com> <1239249521-5013-3-git-send-email-ieidus@redhat.com> <1239249521-5013-4-git-send-email-ieidus@redhat.com> <1239249521-5013-5-git-send-email-ieidus@redhat.com> <20090414150929.174a9b25.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090414150929.174a9b25.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, chrisw@redhat.com, mtosatti@redhat.com, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Tue, Apr 14, 2009 at 03:09:29PM -0700, Andrew Morton wrote:
> We need a comment here explaining why we can't use the much preferable
> lock_page().
> 
> Why can't we use the much preferable lock_page()?

We might but then it'd risk to waste time waiting. It's not worth
waiting, we want kksmd to be allowed to keep one (in future more than
one as we scale it smp/numa) CPU busy at all times running memcmp and
not schedule (other than for need_resched()) to try to free memory at
the fastest peace possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
