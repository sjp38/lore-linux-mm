Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 559756B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 09:13:57 -0400 (EDT)
Date: Mon, 30 May 2011 14:13:53 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bugme-new] [Bug 35512] New: firefox hang, congestion_wait
Message-ID: <20110530131352.GR5044@csn.ul.ie>
References: <bug-35512-10286@https.bugzilla.kernel.org/>
 <20110520125147.a8baa51a.akpm@linux-foundation.org>
 <20110523104447.GK4743@csn.ul.ie>
 <BANLkTi=kTeertYXY7MtqePpM6YP6H67wtQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <BANLkTi=kTeertYXY7MtqePpM6YP6H67wtQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ury Stankevich <urykhy@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Sun, May 29, 2011 at 12:28:34PM +0400, Ury Stankevich wrote:
> Thanks for the patch, i'm using it for a few days with no hangs.
> 

Thanks very much for testing. I've pushed the latest relevant patch
towards mainline. The two other patches have already been pushed.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
