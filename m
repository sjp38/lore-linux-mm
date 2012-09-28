Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 06FF96B005D
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 10:28:30 -0400 (EDT)
Date: Fri, 28 Sep 2012 14:28:29 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] make GFP_NOTRACK flag unconditional
In-Reply-To: <1348826194-21781-1-git-send-email-glommer@parallels.com>
Message-ID: <0000013a0d475174-343e3b17-6755-42c1-9dae-a9287ad7d403-000000@email.amazonses.com>
References: <1348826194-21781-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>

On Fri, 28 Sep 2012, Glauber Costa wrote:

> There was a general sentiment in a recent discussion (See
> https://lkml.org/lkml/2012/9/18/258) that the __GFP flags should be
> defined unconditionally. Currently, the only offender is GFP_NOTRACK,
> which is conditional to KMEMCHECK.
>
> This simple patch makes it unconditional.

__GFP_NOTRACK is only used in context where CONFIG_KMEMCHECK is defined?

If that is not the case then you need to define GFP_NOTRACK and substitute
it where necessary.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
