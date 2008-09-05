Date: Fri, 05 Sep 2008 10:52:10 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/4] pull out zone cpuset and watermark checks for reuse
In-Reply-To: <1220467452-15794-3-git-send-email-apw@shadowen.org>
References: <1220467452-15794-1-git-send-email-apw@shadowen.org> <1220467452-15794-3-git-send-email-apw@shadowen.org>
Message-Id: <20080905105110.5A41.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

> When allocating we need to confirm that the zone we are about to allocate
> from is acceptable to the CPUSET we are in, and that it does not violate
> the zone watermarks.  Pull these checks out so we can reuse them in a
> later patch.
> 
> Signed-off-by: Andy Whitcroft <apw@shadowen.org>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
