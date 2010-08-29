Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C58366B01F0
	for <linux-mm@kvack.org>; Sun, 29 Aug 2010 11:40:48 -0400 (EDT)
Received: by pvc30 with SMTP id 30so2149874pvc.14
        for <linux-mm@kvack.org>; Sun, 29 Aug 2010 08:40:47 -0700 (PDT)
Date: Mon, 30 Aug 2010 00:40:40 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] vmscan: fix missing place to check nr_swap_pages.
Message-ID: <20100829154040.GA2714@barrios-desktop>
References: <1282867897-31201-1-git-send-email-yinghan@google.com>
 <AANLkTimaLBJa9hmufqQy3jk7GD-mJDbg=Dqkaja0nOMk@mail.gmail.com>
 <AANLkTi=xUMSZ7wX-2BtJ0-+2BYLCTW=VPTAErinb5Zd2@mail.gmail.com>
 <AANLkTinP_q7S4_O921hdBoedmTp-7gw0+=4DPHZGmysi@mail.gmail.com>
 <AANLkTin6+nHOowdptW2jaxg9urn3OLf9ArgGzKjWnQLM@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTin6+nHOowdptW2jaxg9urn3OLf9ArgGzKjWnQLM@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 27, 2010 at 09:35:58AM -0700, Ying Han wrote:
 
> Also, we found it is quite often to hit the condition
> inactive_anon_is_low on machine with small numa node size, since the
> zone->inactive_ratio is set based on the zone->present_pages.

What's your memory configuration and memory size?

Now we have zoned page allocator and zoned page reclaimer. 
So it makes sense to me. :)

Anyway, I will resend new version. Thanks, Ying. 
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
