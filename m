Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 8BD7C6B0033
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 13:54:46 -0400 (EDT)
Message-ID: <51E4375E.1010704@zytor.com>
Date: Mon, 15 Jul 2013 10:54:38 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC 4/4] Sparse initialization of struct page array.
References: <1373594635-131067-1-git-send-email-holt@sgi.com> <1373594635-131067-5-git-send-email-holt@sgi.com> <CAE9FiQW1s2UwCY6OjzD3+2wG8SjCr1QyCpajhZbk_XhmnFQW4Q@mail.gmail.com> <20130715174551.GA58640@asylum.americas.sgi.com>
In-Reply-To: <20130715174551.GA58640@asylum.americas.sgi.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Zimmer <nzimmer@sgi.com>
Cc: Yinghai Lu <yinghai@kernel.org>, Robin Holt <holt@sgi.com>, Ingo Molnar <mingo@kernel.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Rob Landley <rob@landley.net>, Mike Travis <travis@sgi.com>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Mel Gorman <mgorman@suse.de>

On 07/15/2013 10:45 AM, Nathan Zimmer wrote:
> 
> I hadn't actually been very happy with having a PG_uninitialized2mib flag.
> It implies if we want to jump to 1Gb pages we would need a second flag,
> PG_uninitialized1gb, for that.  I was thinking of changing it to
> PG_uninitialized and setting page->private to the correct order.
> Thoughts?
> 

Seems straightforward.  The bigger issue is the amount of overhead we
cause by having to check upstack for the initialization status of the
superpages.

I'm concerned, obviously, about lingering overhead that is "forever".
That being said, in the absolutely worst case we could have a counter to
the number of uninitialized pages which when it hits zero we do a static
switch and switch out the initialization code (would have to be undone
on memory hotplug, of course.)

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
