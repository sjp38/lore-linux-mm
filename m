Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id ABF918D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 10:54:57 -0500 (EST)
Date: Thu, 17 Feb 2011 16:54:52 +0100 (CET)
From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH v2] mm: Fix out-of-date comments which refers non-existent
 functions
In-Reply-To: <AANLkTikFEjeVJ2HY_KTv29y63bt_+8SwWm7K3Ywdw570@mail.gmail.com>
Message-ID: <alpine.LNX.2.00.1102171654400.2160@pobox.suse.cz>
References: <1297313788-10905-1-git-send-email-ozaki.ryota@gmail.com> <AANLkTikFEjeVJ2HY_KTv29y63bt_+8SwWm7K3Ywdw570@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Ryota Ozaki <ozaki.ryota@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org

On Thu, 10 Feb 2011, Minchan Kim wrote:

> > From: Ryota Ozaki <ozaki.ryota@gmail.com>
> >
> > do_file_page and do_no_page don't exist anymore, but some comments
> > still refers them. The patch fixes them by replacing them with
> > existing ones.
> >
> > Signed-off-by: Ryota Ozaki <ozaki.ryota@gmail.com>
> > Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Cc: Jiri Kosina <trivial@kernel.org>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

As it's not in linux-next, I have picked it up. Thanks,

-- 
Jiri Kosina
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
