Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B4D596B005C
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 00:35:24 -0400 (EDT)
Date: Wed, 15 Jul 2009 21:35:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] Rename pgmoved variable in shrink_active_list()
Message-Id: <20090715213516.9b47ad16.akpm@linux-foundation.org>
In-Reply-To: <20090716131928.9D25.A69D9226@jp.fujitsu.com>
References: <20090716095119.9D0A.A69D9226@jp.fujitsu.com>
	<20090715201654.550cb640.akpm@linux-foundation.org>
	<20090716131928.9D25.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 16 Jul 2009 13:22:30 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> -#define __add_zone_page_state(__z, __i, __d)	\
> -		__mod_zone_page_state(__z, __i, __d)
> -#define __sub_zone_page_state(__z, __i, __d)	\
> -		__mod_zone_page_state(__z, __i,-(__d))
> -

yeah, whatever, I don't think they add a lot of value personally.

I guess they're a _bit_ clearer than doing __sub_zone_page_state() with
a negated argument.  Shrug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
