Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 0523B6B0074
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 14:21:21 -0400 (EDT)
Date: Thu, 16 Aug 2012 11:21:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [announce] pagemap-demo-ng tools
Message-Id: <20120816112120.952c74e8.akpm@linux-foundation.org>
In-Reply-To: <201206261811.48256.b.zolnierkie@samsung.com>
References: <201206261811.48256.b.zolnierkie@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Kyungmin Park <kyungmin.park@samsung.com>

On Tue, 26 Jun 2012 18:11:48 +0200
Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com> wrote:

> I got agreement from Matt to takeover maintenance of demo scripts
> for the /proc/$pid/pagemap and /proc/kpage[count,flags] interfaces
> (originally hosted at http://selenic.com/repo/pagemap/).
> 
> The updated tools are available at:
> 
> 	https://github.com/bzolnier/pagemap-demo-ng

Have you given any thought to putting these into the kernel tree
somewhere and maintaining them that way?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
