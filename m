Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E67F39000BD
	for <linux-mm@kvack.org>; Fri, 23 Sep 2011 11:57:41 -0400 (EDT)
Subject: Re: [PATCH] thp: tail page refcounting fix #6
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 23 Sep 2011 17:57:12 +0200
In-Reply-To: <20110908165118.GC24539@redhat.com>
References: <20110824002717.GI23870@redhat.com>
	 <20110824133459.GP23870@redhat.com> <20110826062436.GA5847@google.com>
	 <20110826161048.GE23870@redhat.com> <20110826185430.GA2854@redhat.com>
	 <20110827094152.GA16402@google.com> <20110827173421.GA2967@redhat.com>
	 <CAEwNFnDk0bQZKReKccuQMPEw_6EA2DxN4dm9cmjr01BVT4A7Dw@mail.gmail.com>
	 <20110901152417.GF10779@redhat.com>
	 <20110901170353.6f92b50f.akpm@linux-foundation.org>
	 <20110908165118.GC24539@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1316793432.9084.47.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, "Paul
 E. McKenney" <paulmck@linux.vnet.ibm.com>

On Thu, 2011-09-08 at 18:51 +0200, Andrea Arcangeli wrote:

> +++ b/arch/powerpc/mm/gup.c
> +++ b/arch/x86/mm/gup.c

lacking a diffstat a quick look seems to suggest you missed a few:

$ ls arch/*/mm/gup.c
arch/powerpc/mm/gup.c =20
arch/s390/mm/gup.c =20
arch/sh/mm/gup.c =20
arch/sparc/mm/gup.c =20
arch/x86/mm/gup.c


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
