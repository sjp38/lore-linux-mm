Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9F7956B02A9
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 13:53:09 -0400 (EDT)
Received: by bwz9 with SMTP id 9so4263496bwz.14
        for <linux-mm@kvack.org>; Tue, 13 Jul 2010 10:53:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTikMcPcldBh_uVKxrH7rEIUju3Y_3X2jLi9jw2Vs@mail.gmail.com>
References: <1278756333-6850-1-git-send-email-lliubbo@gmail.com>
	<AANLkTikMcPcldBh_uVKxrH7rEIUju3Y_3X2jLi9jw2Vs@mail.gmail.com>
Date: Tue, 13 Jul 2010 20:53:11 +0300
Message-ID: <AANLkTinif3HZDfS6UEHS5v2b1qVdU3qqStEjE7bOIWks@mail.gmail.com>
Subject: Re: [PATCH] slob_free:free objects to their own list
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mpm@selenic.com, hannes@cmpxchg.org, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 13, 2010 at 8:52 PM, Pekka Enberg <penberg@cs.helsinki.fi> wrote:
> It would be nice to have some fragmentation numbers for this. One
> really simple test case is to grep for MemTotal and MemFree in
> /proc/meminfo. I'd expect to see some small improvement with your
> patch applied.

Small correction: grep them immediately after you've booted up the
kernel. If you run applications, the numbers are not comparable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
