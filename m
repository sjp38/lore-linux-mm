Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id A26376B016A
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 19:45:32 -0400 (EDT)
Date: Fri, 2 Sep 2011 01:45:27 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] thp: tail page refcounting fix #5
Message-ID: <20110901234527.GD7761@one.firstfloor.org>
References: <20110824002717.GI23870@redhat.com> <20110824133459.GP23870@redhat.com> <20110826062436.GA5847@google.com> <20110826161048.GE23870@redhat.com> <20110826185430.GA2854@redhat.com> <20110827094152.GA16402@google.com> <20110827173421.GA2967@redhat.com> <CAEwNFnDk0bQZKReKccuQMPEw_6EA2DxN4dm9cmjr01BVT4A7Dw@mail.gmail.com> <20110901152417.GF10779@redhat.com> <20110901162808.80a2117c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110901162808.80a2117c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andi Kleen <andi@firstfloor.org>

On Thu, Sep 01, 2011 at 04:28:08PM -0700, Andrew Morton wrote:
> On Thu, 1 Sep 2011 17:24:17 +0200
> Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
> > Ideally direct-io should stop calling get_page() on pages
> > returned by get_user_pages().
> 
> Yeah.  get_user_pages() is sufficient.  Ideally we should be able to
> undo the get_user_pages() get_page() from within the IO completion
> interrupt and we're done.
> 
> Cc Andi, who is our resident dio tweaker ;)
> 

Noted, I'll put it on my list.

Should not be too difficult from a quick look, just the convoluted
nature of direct-io.c requires a lot of double checking.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
