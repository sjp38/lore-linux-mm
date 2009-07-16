Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B12096B005A
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 23:17:02 -0400 (EDT)
Date: Wed, 15 Jul 2009 20:16:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] Rename pgmoved variable in shrink_active_list()
Message-Id: <20090715201654.550cb640.akpm@linux-foundation.org>
In-Reply-To: <20090716095119.9D0A.A69D9226@jp.fujitsu.com>
References: <20090716094619.9D07.A69D9226@jp.fujitsu.com>
	<20090716095119.9D0A.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 16 Jul 2009 09:52:34 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

>  	if (file)
> -		__mod_zone_page_state(zone, NR_ACTIVE_FILE, -pgmoved);
> +		__mod_zone_page_state(zone, NR_ACTIVE_FILE, -nr_taken);
>  	else
> -		__mod_zone_page_state(zone, NR_ACTIVE_ANON, -pgmoved);
> +		__mod_zone_page_state(zone, NR_ACTIVE_ANON, -nr_taken);

we could have used __sub_zone_page_state() there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
