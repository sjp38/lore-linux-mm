Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 793BE6B0130
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 10:02:58 -0400 (EDT)
Date: Mon, 11 Jun 2012 09:02:56 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: fix protection column misplacing in /proc/zoneinfo
In-Reply-To: <1339422650-9798-1-git-send-email-kosaki.motohiro@gmail.com>
Message-ID: <alpine.DEB.2.00.1206110856180.31180@router.home>
References: <1339422650-9798-1-git-send-email-kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Mon, 11 Jun 2012, kosaki.motohiro@gmail.com wrote:

> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>
> commit 2244b95a7b (zoned vm counters: basic ZVC (zoned vm counter)
> implementation) broke protection column. It is a part of "pages"
> attribute. but not it is showed after vmstats column.
>
> This patch restores the right position.

Well this reorders the output. vmstats are also counts of pages. I am not
sure what the difference is.

You are not worried about breaking something that may scan the zoneinfo
output with this change? Its been this way for 6 years and its likely that
tools expect the current layout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
