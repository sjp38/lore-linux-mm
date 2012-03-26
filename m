Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 16F616B0044
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 09:56:13 -0400 (EDT)
Date: Mon, 26 Mar 2012 14:56:09 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] Re: kswapd stuck using 100% CPU
Message-ID: <20120326135609.GM1007@csn.ul.ie>
References: <20120324130353.48f2e4c8@kryten>
 <20120324102621.353114da@annuminas.surriel.com>
 <20120326093201.GL1007@csn.ul.ie>
 <CAOJsxLGcoxxdhe2sNmAbC2e5afnZm9960XxBjY+QoCoc0RRb2w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAOJsxLGcoxxdhe2sNmAbC2e5afnZm9960XxBjY+QoCoc0RRb2w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Anton Blanchard <anton@samba.org>, aarcange@redhat.com, akpm@linux-foundation.org, hughd@google.com, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, Mar 26, 2012 at 01:40:41PM +0300, Pekka Enberg wrote:
> On Mon, Mar 26, 2012 at 12:32 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> > On Sat, Mar 24, 2012 at 10:26:21AM -0400, Rik van Riel wrote:
> >>
> >> Only test compaction_suitable if the kernel is built with CONFIG_COMPACTION,
> >> otherwise the stub compaction_suitable function will always return
> >> COMPACT_SKIPPED and send kswapd into an infinite loop.
> >>
> >> Signed-off-by: Rik van Riel <riel@redhat.com>
> >> Reported-by: Anton Blanchard <anton@samba.org>
> >
> > Acked-by: Mel Gorman <mel@csn.ul.ie>
> 
> The API looks fragile and this patch isn't exactly making it any
> better. Why don't we make compaction_suitable() return something other
> than COMPACT_SKIPPED for !CONFIG_COMPACTION case?
> 

Returning COMPACT_PARTIAL or COMPACT_CONTINUE would confuse the check in
should_continue_reclaim. A fourth return type could be added but an
obvious name does not spring to mind that would end up being similar to
just adding a CONFIG_COMPACTION check.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
