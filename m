Date: Fri, 05 Sep 2008 10:52:10 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] pull out the page pre-release and sanity check logic for reuse
In-Reply-To: <1220467452-15794-2-git-send-email-apw@shadowen.org>
References: <1220467452-15794-1-git-send-email-apw@shadowen.org> <1220467452-15794-2-git-send-email-apw@shadowen.org>
Message-Id: <20080905105124.5A44.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

> When we are about to release a page we perform a number of actions
> on that page.  We clear down any anonymous mappings, confirm that
> the page is safe to release, check for freeing locks, before mapping
> the page should that be required.  Pull this processing out into a
> helper function for reuse in a later patch.
> 
> Note that we do not convert the similar cleardown in free_hot_cold_page()
> as the optimiser is unable to squash the loops during the inline.
> 
> Signed-off-by: Andy Whitcroft <apw@shadowen.org>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
