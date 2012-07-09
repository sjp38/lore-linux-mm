Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 2C7D06B006C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 16:53:31 -0400 (EDT)
Date: Mon, 9 Jul 2012 13:53:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Warn about costly page allocation
Message-Id: <20120709135329.40fbfe20.akpm@linux-foundation.org>
In-Reply-To: <20120709131942.GA3594@barrios>
References: <1341801500-5798-1-git-send-email-minchan@kernel.org>
	<20120709082200.GX14154@suse.de>
	<20120709084657.GA7915@bbox>
	<20120709091203.GY14154@suse.de>
	<20120709125048.GA2203@barrios>
	<20120709130551.GA14154@suse.de>
	<20120709131942.GA3594@barrios>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, 9 Jul 2012 22:19:42 +0900
Minchan Kim <minchan@kernel.org> wrote:

> > As you are using printk_ratelimit()

include/linux/printk.h sayeth

/*
 * Please don't use printk_ratelimit(), because it shares ratelimiting state
 * with all other unrelated printk_ratelimit() callsites.  Instead use
 * printk_ratelimited() or plain old __ratelimit().
 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
