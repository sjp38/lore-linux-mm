Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id B77EA6B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 03:08:42 -0400 (EDT)
Received: from mail-ea0-f169.google.com ([209.85.215.169])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1TO1Gb-0000Hd-MM
	for linux-mm@kvack.org; Tue, 16 Oct 2012 07:08:41 +0000
Received: by mail-ea0-f169.google.com with SMTP id k11so1503354eaa.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 00:08:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121016054946.GA3934@barrios>
References: <1350278059-14904-1-git-send-email-ming.lei@canonical.com>
	<1350278059-14904-2-git-send-email-ming.lei@canonical.com>
	<20121015154724.GA2840@barrios>
	<CACVXFVM09H=8ZuFSzkcN1NmOCR1pcPUsuUyT9tpR0doVam2BiQ@mail.gmail.com>
	<20121016054946.GA3934@barrios>
Date: Tue, 16 Oct 2012 15:08:41 +0800
Message-ID: <CACVXFVOdohPprD7N69=Tz2keTbLG7b-s5324OUX-oY84Jszumg@mail.gmail.com>
Subject: Re: [RFC PATCH 1/3] mm: teach mm by current context info to not do
 I/O during memory allocation
From: Ming Lei <ming.lei@canonical.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Jiri Kosina <jiri.kosina@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm <linux-mm@kvack.org>

On Tue, Oct 16, 2012 at 1:49 PM, Minchan Kim <minchan@kernel.org> wrote:
>
> Fair enough but it wouldn't be a good idea that add new unlikely branch
> in allocator's fast path. Please move the check into slow path which could
> be in __alloc_pages_slowpath.

Thanks for your comment.

I have considered to add the branch into gfp_to_alloc_flags() before,
but didn't do it because I see that get_page_from_freelist() may use
the GFP_IO or GFP_FS flag at least in zone_reclaim() path.

So could you make sure it is safe to move the branch into
__alloc_pages_slowpath()?  If so, I will add the check into
gfp_to_alloc_flags().


Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
