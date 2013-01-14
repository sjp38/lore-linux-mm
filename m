Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id A5DF66B006E
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 08:09:13 -0500 (EST)
Date: Mon, 14 Jan 2013 13:09:11 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Unique commit-id for "mm: compaction: [P,p]artially revert
 capture of suitable high-order page"
Message-ID: <20130114130911.GQ13304@suse.de>
References: <CA+icZUW5kryOCpX96CkaS=5uX61FmiYE0mh7y6F0eT9Bh8eUGw@mail.gmail.com>
 <20130114103612.GO13304@suse.de>
 <CA+icZUUReY7LPjnF1xTjD-aJSYYqgo9tF9K8T8--r_HjRwgCHA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+icZUUReY7LPjnF1xTjD-aJSYYqgo9tF9K8T8--r_HjRwgCHA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sedat Dilek <sedat.dilek@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, stable@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jan 14, 2013 at 12:27:20PM +0100, Sedat Dilek wrote:
> On Mon, Jan 14, 2013 at 11:36 AM, Mel Gorman <mgorman@suse.de> wrote:
> > On Sun, Jan 13, 2013 at 05:12:45PM +0100, Sedat Dilek wrote:
> >> Hi Linus,
> >>
> >> I see two different commit-id for an identical patch (only subject
> >> line differs).
> >> [1] seems to be applied directly and [2] came with a merge of akpm-fixes.
> >> What is in case of backports for -stable kernels?
> >
> > I do not expect it to matter. I was going to use
> > 8fb74b9fb2b182d54beee592350d9ea1f325917a as the commit ID whenever I got
> > the complaint mail from Greg's tools about a 3.7 merge failure. The 3.7.2
> > backport looks like this.
> >
> 
> Oh cool and thanks!
> Are you planning to resend this backport-patch to the lists w/ a "3.7"
> (or for-3.7) in the commit-subject?
> 

Yes, when I get the reject mail from Greg's tools.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
