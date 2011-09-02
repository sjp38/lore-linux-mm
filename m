Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3E9E66B016A
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 21:17:22 -0400 (EDT)
Date: Fri, 2 Sep 2011 03:17:16 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] thp: tail page refcounting fix #5
Message-ID: <20110902011716.GE7761@one.firstfloor.org>
References: <20110826062436.GA5847@google.com> <20110826161048.GE23870@redhat.com> <20110826185430.GA2854@redhat.com> <20110827094152.GA16402@google.com> <20110827173421.GA2967@redhat.com> <CAEwNFnDk0bQZKReKccuQMPEw_6EA2DxN4dm9cmjr01BVT4A7Dw@mail.gmail.com> <20110901152417.GF10779@redhat.com> <20110901162808.80a2117c.akpm@linux-foundation.org> <20110901234527.GD7761@one.firstfloor.org> <20110902002013.GJ10779@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110902002013.GJ10779@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

> Calling get_page/put_pages more times than necessary is never ideal, I
> imagine the biggest cost is the atomic_inc on the head page that

I've actually seen it in profile logs, but I hadn't realized it was redundant.

Have to see if it brings a benefit to hot users.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
