Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3A29C900001
	for <linux-mm@kvack.org>; Thu, 12 May 2011 14:36:21 -0400 (EDT)
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <BANLkTimDsJDht76Vm7auNqT2gncjpEKZQw@mail.gmail.com>
References: <1305127773-10570-1-git-send-email-mgorman@suse.de>
	 <1305127773-10570-4-git-send-email-mgorman@suse.de>
	 <alpine.DEB.2.00.1105120942050.24560@router.home>
	 <1305213359.2575.46.camel@mulgrave.site>
	 <alpine.DEB.2.00.1105121024350.26013@router.home>
	 <1305214993.2575.50.camel@mulgrave.site> <20110512154649.GB4559@redhat.com>
	 <1305216023.2575.54.camel@mulgrave.site>
	 <alpine.DEB.2.00.1105121121120.26013@router.home>
	 <1305217843.2575.57.camel@mulgrave.site>
	 <BANLkTi=MD+voG1i7uDyueV22_daGHPRdqw@mail.gmail.com>
	 <BANLkTimDsJDht76Vm7auNqT2gncjpEKZQw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 12 May 2011 13:36:15 -0500
Message-ID: <1305225375.2575.65.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>

On Thu, 2011-05-12 at 20:11 +0300, Pekka Enberg wrote:
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

So yes, it's a default FC15 config.

Disabling THP was initially tried a long time ago and didn't make a
difference (it was originally suggested by Chris Mason).

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
