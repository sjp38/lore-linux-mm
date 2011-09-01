Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6139A6B016A
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 19:28:51 -0400 (EDT)
Date: Thu, 1 Sep 2011 16:28:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] thp: tail page refcounting fix #5
Message-Id: <20110901162808.80a2117c.akpm@linux-foundation.org>
In-Reply-To: <20110901152417.GF10779@redhat.com>
References: <CANN689HE=TKyr-0yDQgXEoothGJ0Cw0HLB2iOvCKrOXVF2DNww@mail.gmail.com>
	<20110824000914.GH23870@redhat.com>
	<20110824002717.GI23870@redhat.com>
	<20110824133459.GP23870@redhat.com>
	<20110826062436.GA5847@google.com>
	<20110826161048.GE23870@redhat.com>
	<20110826185430.GA2854@redhat.com>
	<20110827094152.GA16402@google.com>
	<20110827173421.GA2967@redhat.com>
	<CAEwNFnDk0bQZKReKccuQMPEw_6EA2DxN4dm9cmjr01BVT4A7Dw@mail.gmail.com>
	<20110901152417.GF10779@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andi Kleen <andi@firstfloor.org>

On Thu, 1 Sep 2011 17:24:17 +0200
Andrea Arcangeli <aarcange@redhat.com> wrote:

> Ideally direct-io should stop calling get_page() on pages
> returned by get_user_pages().

Yeah.  get_user_pages() is sufficient.  Ideally we should be able to
undo the get_user_pages() get_page() from within the IO completion
interrupt and we're done.

Cc Andi, who is our resident dio tweaker ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
