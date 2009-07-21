Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1E3686B004D
	for <linux-mm@kvack.org>; Tue, 21 Jul 2009 14:01:04 -0400 (EDT)
Date: Tue, 21 Jul 2009 20:01:00 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 06/10] ksm: identify PageKsm pages
Message-ID: <20090721180059.GG2239@random.random>
References: <1247851850-4298-1-git-send-email-ieidus@redhat.com>
 <1247851850-4298-2-git-send-email-ieidus@redhat.com>
 <1247851850-4298-3-git-send-email-ieidus@redhat.com>
 <1247851850-4298-4-git-send-email-ieidus@redhat.com>
 <1247851850-4298-5-git-send-email-ieidus@redhat.com>
 <1247851850-4298-6-git-send-email-ieidus@redhat.com>
 <1247851850-4298-7-git-send-email-ieidus@redhat.com>
 <20090721175139.GE2239@random.random>
 <4A660101.3000307@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A660101.3000307@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Izik Eidus <ieidus@redhat.com>, akpm@linux-foundation.org, hugh.dickins@tiscali.co.uk, chrisw@redhat.com, avi@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 21, 2009 at 01:55:13PM -0400, Rik van Riel wrote:
> I guess that if they are to remain unswappable, they
> should go onto the unevictable list.

They should indeed. Not urgent but it will optimize the vm (as in
virtual memory) cpu load a bit.

> Then again, I'm guessing this is all about to change
> in not too much time :)

That's my point, current implementation of PageKsm don't seem to last
long, and if we keep logic the same it'll likely happen soon that
PageKsm != PageAnon on a Ksm page. So I'd rather keep it different
even now, given I doubt it's moving the needle anywhere in ksm code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
