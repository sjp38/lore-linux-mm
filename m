Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B186A6B005D
	for <linux-mm@kvack.org>; Tue, 21 Jul 2009 13:59:13 -0400 (EDT)
Date: Tue, 21 Jul 2009 19:59:09 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00/10] ksm resend
Message-ID: <20090721175909.GF2239@random.random>
References: <1247851850-4298-1-git-send-email-ieidus@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1247851850-4298-1-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: akpm@linux-foundation.org, hugh.dickins@tiscali.co.uk, chrisw@redhat.com, avi@redhat.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Fri, Jul 17, 2009 at 08:30:40PM +0300, Izik Eidus wrote:
> The code still need to get Andrea Arcangeli acks.
> (he was busy and will ack it later).

Ack it all except that detail in 6/10 as I'm unconvinced about ksm
pages having to return 1 on PageAnon check. I believe they deserve a
different bitflag in the mapping pointer. The smallest possible
alignment for mapping pointer is 4 on 32bit archs so there is space
for it and later it can be renamed EXTERNAL to generalize. We shall
make good use of that bitflag as it's quite precious to introduce
non-linearity in linear vmas, and not wire it to KSM only. But in
meantime we'll get better testing coverage by not having that PageKsm
== PageAnon invariant I think that I doubt we're going to retain (at
least with this implementation of PageKsm).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
