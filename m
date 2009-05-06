Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A42426B0098
	for <linux-mm@kvack.org>; Wed,  6 May 2009 10:08:59 -0400 (EDT)
Date: Wed, 6 May 2009 16:09:04 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/6] ksm: dont allow overlap memory addresses
	registrations.
Message-ID: <20090506140904.GY16078@random.random>
References: <1241475935-21162-1-git-send-email-ieidus@redhat.com> <1241475935-21162-2-git-send-email-ieidus@redhat.com> <1241475935-21162-3-git-send-email-ieidus@redhat.com> <4A00DD4F.8010101@redhat.com> <4A015C69.7010600@redhat.com> <4A0181EA.3070600@redhat.com> <20090506131735.GW16078@random.random> <Pine.LNX.4.64.0905061424480.19190@blonde.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0905061424480.19190@blonde.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Rik van Riel <riel@redhat.com>, Izik Eidus <ieidus@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, chrisw@redhat.com, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Wed, May 06, 2009 at 02:28:33PM +0100, Hugh Dickins wrote:
> There may prove to be various reasons why it wouldn't work out in practice;
> but when thinking of swapping them, it is worth considering if those KSM
> pages can just be assigned to a tmpfs file, then leave the swapping to that.

Not sure if I understand but the vma handled by KSM is anonymous, how
can you assign those pages to a tmpfs file, the anon vma won't permit
that, all regular anon methods will be called for swapin etc... What I
mean is that some change in core VM looks required and I plan those to
be external-rmap kind, KSM agnostic. But perhaps we can reuse some
shmem code yes, I didn't think about that yet. Anyway I'd rather
discuss this later, this isn't the time yet. I'm quite optimistic that
to make KSM swap it won't be a big change. For now there's a limit on
the max number of ksm pages that can be allocated at any given time so
to avoid OOM conditions, like the swap-compress logic that limits the
swapdevice size to less than ram.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
