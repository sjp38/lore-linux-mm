Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 196DF6B00CA
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 09:04:36 -0400 (EDT)
Date: Thu, 21 Jun 2012 14:04:32 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm: offlining memory may block forever
Message-ID: <20120621130432.GB3953@csn.ul.ie>
References: <CAEtiSau6dRYVOSD4-QUWkYZ8p7z1ATLHZY9v871VS=o0LduU_Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAEtiSau6dRYVOSD4-QUWkYZ8p7z1ATLHZY9v871VS=o0LduU_Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaditya Kumar <aaditya.kumar.30@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org, kosaki.motohiro@jp.fujitsu.com, gregkh@linuxfoundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.cz>, tim.bird@am.sony.com, frank.rowand@am.sony.com, takuzo.ohara@ap.sony.com, kan.iibuchi@jp.sony.com, aaditya.kumar@ap.sony.com

On Wed, Jun 20, 2012 at 09:53:31PM +0530, Aaditya Kumar wrote:
> Offlining memory may block forever, waiting for kswapd() to wake up because
> kswapd() does not check the event kthread->should_stop before sleeping.
> 

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
