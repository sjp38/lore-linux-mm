Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1JMGorc032189
	for <linux-mm@kvack.org>; Tue, 19 Feb 2008 17:16:50 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1JMH1c5189572
	for <linux-mm@kvack.org>; Tue, 19 Feb 2008 15:17:01 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1JMH0b5008400
	for <linux-mm@kvack.org>; Tue, 19 Feb 2008 15:17:00 -0700
Subject: Re: [LTP] [PATCH 1/8] Scaling msgmni to the amount of lowmem
From: Matt Helsley <matthltc@us.ibm.com>
In-Reply-To: <47BB0EDC.5000002@bull.net>
References: <20080211141646.948191000@bull.net>
	 <20080211141813.354484000@bull.net>
	 <20080215215916.8566d337.akpm@linux-foundation.org>
	 <47B94D8C.8040605@bull.net>  <47B9835A.3060507@bull.net>
	 <1203411055.4612.5.camel@subratamodak.linux.ibm.com>
	 <47BB0EDC.5000002@bull.net>
Content-Type: text/plain
Date: Tue, 19 Feb 2008 14:16:58 -0800
Message-Id: <1203459418.7408.39.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nadia Derbey <Nadia.Derbey@bull.net>
Cc: subrata@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, ltp-list@lists.sourceforge.net, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cmm@us.ibm.com, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Tue, 2008-02-19 at 18:16 +0100, Nadia Derbey wrote:

<snip>

> +#define MAX_MSGQUEUES  16      /* MSGMNI as defined in linux/msg.h */
> +

It's not quite the maximum anymore, is it? More like the minumum
maximum ;). A better name might better document what the test is
actually trying to do.

One question I have is whether the unpatched test is still valuable.
Based on my limited knowledge of the test I suspect it's still a correct
test of message queues. If so, perhaps renaming the old test (so it's
not confused with a performance regression) and adding your patched
version is best?

<snip>

Cheers,
	-Matt Helsley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
