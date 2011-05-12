Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8C9DB900001
	for <linux-mm@kvack.org>; Thu, 12 May 2011 13:38:43 -0400 (EDT)
Date: Thu, 12 May 2011 12:38:34 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
In-Reply-To: <BANLkTimDsJDht76Vm7auNqT2gncjpEKZQw@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1105121232110.28493@router.home>
References: <1305127773-10570-1-git-send-email-mgorman@suse.de> <1305127773-10570-4-git-send-email-mgorman@suse.de> <alpine.DEB.2.00.1105120942050.24560@router.home> <1305213359.2575.46.camel@mulgrave.site> <alpine.DEB.2.00.1105121024350.26013@router.home>
 <1305214993.2575.50.camel@mulgrave.site> <20110512154649.GB4559@redhat.com> <1305216023.2575.54.camel@mulgrave.site> <alpine.DEB.2.00.1105121121120.26013@router.home> <1305217843.2575.57.camel@mulgrave.site> <BANLkTi=MD+voG1i7uDyueV22_daGHPRdqw@mail.gmail.com>
 <BANLkTimDsJDht76Vm7auNqT2gncjpEKZQw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>

On Thu, 12 May 2011, Pekka Enberg wrote:

> On Thu, May 12, 2011 at 8:06 PM, Pekka Enberg <penberg@kernel.org> wrote:
> > On Thu, May 12, 2011 at 7:30 PM, James Bottomley
> > <James.Bottomley@hansenpartnership.com> wrote:
> >> So suggest an alternative root cause and a test to expose it.
> >
> > Is your .config available somewhere, btw?
>
> If it's this:
>
> http://pkgs.fedoraproject.org/gitweb/?p=kernel.git;a=blob_plain;f=config-x86_64-generic;hb=HEAD
>
> I'd love to see what happens if you disable
>
> CONFIG_TRANSPARENT_HUGEPAGE=y
>
> because that's going to reduce high order allocations as well, no?

I dont think that will change much since huge pages are at MAX_ORDER size.
Either you can get them or not. The challenge with the small order
allocations is that they require contiguous memory. Compaction is likely
not as effective as the prior mechanism that did opportunistic reclaim of
neighboring pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
