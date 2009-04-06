Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C7EC55F0001
	for <linux-mm@kvack.org>; Mon,  6 Apr 2009 09:42:07 -0400 (EDT)
Date: Mon, 6 Apr 2009 15:42:41 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/4] ksm - dynamic page sharing driver for linux v2
Message-ID: <20090406134240.GK9137@random.random>
References: <1238855722-32606-1-git-send-email-ieidus@redhat.com> <200904061704.50052.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200904061704.50052.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Izik Eidus <ieidus@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, chrisw@redhat.com, mtosatti@redhat.com, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Mon, Apr 06, 2009 at 05:04:49PM +1000, Nick Piggin wrote:
> They should use a shared memory segment, or MAP_ANONYMOUS|MAP_SHARED etc.
> Presumably they will probably want to control it to interleave it over
> all numa nodes and use hugepages for it. It would be very little work.

I thought it's the intermediate result of the computations that leads
to lots of equal data too, in which case ksm is the only way to share
it all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
