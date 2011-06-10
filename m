Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id AB1896B0012
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 18:24:35 -0400 (EDT)
Received: from mail-wy0-f169.google.com (mail-wy0-f169.google.com [74.125.82.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p5AMOW1Q028049
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 15:24:33 -0700
Received: by wyf19 with SMTP id 19so2855534wyf.14
        for <linux-mm@kvack.org>; Fri, 10 Jun 2011 15:24:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1306922672-9012-1-git-send-email-dbaryshkov@gmail.com>
References: <1306922672-9012-1-git-send-email-dbaryshkov@gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 10 Jun 2011 15:24:11 -0700
Message-ID: <BANLkTimm_nD77BV8CLSGF95+E7JP1sv6ig@mail.gmail.com>
Subject: Re: [PATCH] Make GFP_DMA allocations w/o ZONE_DMA emit a warning
 instead of failing
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Jun 1, 2011 at 3:04 AM, Dmitry Eremin-Solenikov
<dbaryshkov@gmail.com> wrote:
> Please be more polite to other people. After a197b59ae6 all allocations
> with GFP_DMA set on nodes without ZONE_DMA fail nearly silently (only
> one warning during bootup is emited, no matter how many things fail).
> This is a very crude change on behaviour. To be more civil, instead of
> failing emit noisy warnings each time smbd. tries to allocate a GFP_DMA
> memory on non-ZONE_DMA node.

The whole thing already got reverted in commit 1fa7b6a29c613.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
