Date: Thu, 31 Jan 2008 05:48:19 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 05/19] split LRU lists into anon & file sets
Message-ID: <20080131054819.6be037f8@riellaptop.surriel.com>
In-Reply-To: <20080131100838.1F3B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080130175439.1AFD.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<1201703382.5459.3.camel@localhost>
	<20080131100838.1F3B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jan 2008 10:17:48 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> on my test environment, my patch solve incorrect OOM.
> because, too small reclaim cause OOM.

That makes sense.

The version you two are looking at can return
"percentages" way larger than 100 in get_scan_ratio.

A fixed version of get_scan_ratio, where the
percentages always add up to 100%, makes the
system go OOM before it seriously starts
swapping.

I will integrate your fixes with my code when I
get back from holidays.  Then things should work :)

Thank you for your analysis of the problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
