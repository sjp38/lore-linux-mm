Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 567ED5F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 18:14:36 -0400 (EDT)
Date: Tue, 14 Apr 2009 15:09:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/4] ksm - dynamic page sharing driver for linux v3
Message-Id: <20090414150903.b01fa3b9.akpm@linux-foundation.org>
In-Reply-To: <1239249521-5013-1-git-send-email-ieidus@redhat.com>
References: <1239249521-5013-1-git-send-email-ieidus@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, mtosatti@redhat.com, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu,  9 Apr 2009 06:58:37 +0300
Izik Eidus <ieidus@redhat.com> wrote:

> KSM is a linux driver that allows dynamicly sharing identical memory
> pages between one or more processes.

Generally looks OK to me.  But that doesn't mean much.  We should rub
bottles with words like "hugh" and "nick" on them to be sure.


>
> ...
>
>  include/linux/ksm.h          |   48 ++
>  include/linux/miscdevice.h   |    1 +
>  include/linux/mm.h           |    5 +
>  include/linux/mmu_notifier.h |   34 +
>  include/linux/rmap.h         |   11 +
>  mm/Kconfig                   |    6 +
>  mm/Makefile                  |    1 +
>  mm/ksm.c                     | 1674 ++++++++++++++++++++++++++++++++++++++++++
>  mm/memory.c                  |   90 +++-
>  mm/mmu_notifier.c            |   20 +
>  mm/rmap.c                    |  139 ++++

And it's pretty unobtrusive for what it is.  I expect we can get this
into 2.6.31 unless there are some pratfalls which I missed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
