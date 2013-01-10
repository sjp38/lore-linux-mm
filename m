Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 1B6D66B0070
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 16:58:30 -0500 (EST)
Date: Thu, 10 Jan 2013 13:58:28 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm: forcely swapout when we are out of page cache
Message-Id: <20130110135828.c88bcaf1.akpm@linux-foundation.org>
In-Reply-To: <20130110022306.GB14685@blaptop>
References: <1357712474-27595-1-git-send-email-minchan@kernel.org>
	<1357712474-27595-3-git-send-email-minchan@kernel.org>
	<20130109162602.53a60e77.akpm@linux-foundation.org>
	<20130110022306.GB14685@blaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Sonny Rao <sonnyrao@google.com>, Bryan Freed <bfreed@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

On Thu, 10 Jan 2013 11:23:06 +0900
Minchan Kim <minchan@kernel.org> wrote:

> > I have a feeling that laptop mode has bitrotted and these patches are
> > kinda hacking around as-yet-not-understood failures...
> 
> Absolutely, this patch is last guard for unexpectable behavior.
> As I mentioned in cover-letter, Luigi's problem could be solved either [1/2]
> or [2/2] but I wanted to add this as last resort in case of unexpected
> emergency. But you're right. It's not good to hide the problem like this path
> so let's drop [2/2].
> 
> Also, I absolutely agree it has bitrotted so for correcting it, we need a
> volunteer who have to inverstigate power saveing experiment with long time.
> So [1/2] would be band-aid until that.

I'm inclined to hold off on 1/2 as well, really.

The point of laptop_mode isn't to save power btw - it is to minimise
the frequency with which the disk drive is spun up.  By deferring and
then batching writeout operations, basically.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
