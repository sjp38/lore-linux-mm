Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 56F5A6B0069
	for <linux-mm@kvack.org>; Mon, 31 Oct 2011 13:54:00 -0400 (EDT)
Date: Mon, 31 Oct 2011 17:34:22 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: kernel 3.0: BUG: soft lockup: find_get_pages+0x51/0x110
Message-ID: <20111031163422.GC3466@redhat.com>
References: <201110122012.33767.pluto@agmk.net>
 <20111021155632.GD4082@suse.de>
 <20111021174120.GJ608@redhat.com>
 <201110221307.11615.nai.xia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201110221307.11615.nai.xia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

Hi Nai,

On Sat, Oct 22, 2011 at 01:07:11PM +0800, Nai Xia wrote:
> Yeah, anon_vma root lock is a big lock. And JFYI, actually I am doing 
> some very nasty hacking on anon_vma and one of the side effects is 
> breaking the root lock into pieces. But this area is pretty 
> convolved by many racing conditions. I hope some day I will finally make
> my patch work and have your precious review of it. :-)

:) It's going to be not trivial, initially it was not a shared lock
but it wasn't safe that way (especially with migrate required a
reliable rmap_walk) and using a shared lock across all
same_anon_vma/same_vma lists was the only way to be safe and solve the
races.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
