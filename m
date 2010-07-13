Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E56336B02A3
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 17:53:52 -0400 (EDT)
Subject: Re: [PATCH] slob_free:free objects to their own list
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <AANLkTikMcPcldBh_uVKxrH7rEIUju3Y_3X2jLi9jw2Vs@mail.gmail.com>
References: <1278756333-6850-1-git-send-email-lliubbo@gmail.com>
	 <AANLkTikMcPcldBh_uVKxrH7rEIUju3Y_3X2jLi9jw2Vs@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 13 Jul 2010 16:53:47 -0500
Message-ID: <1279058027.936.236.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Bob Liu <lliubbo@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-07-13 at 20:52 +0300, Pekka Enberg wrote:
> Hi Bob,
> 
> [ Please CC me on SLOB patches. You can use the 'scripts/get_maintainer.pl'
>   script to figure out automatically who to CC on your patches. ]
> 
> On Sat, Jul 10, 2010 at 1:05 PM, Bob Liu <lliubbo@gmail.com> wrote:
> > slob has alloced smaller objects from their own list in reduce
> > overall external fragmentation and increase repeatability,
> > free to their own list also.
> >
> > Signed-off-by: Bob Liu <lliubbo@gmail.com>
> 
> The patch looks sane to me. Matt, does it look OK to you as well?

Yep, this should be a marginal improvement.

Acked-by: Matt Mackall <mpm@selenic.com>

-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
