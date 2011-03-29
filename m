Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id EFB2B8D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 11:35:11 -0400 (EDT)
Message-ID: <4D91FC2D.4090602@redhat.com>
Date: Tue, 29 Mar 2011 11:35:09 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: [LSF][MM] page allocation & direct reclaim latency
References: <1301373398.2590.20.camel@mulgrave.site>
In-Reply-To: <1301373398.2590.20.camel@mulgrave.site>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf@lists.linux-foundation.org
Cc: linux-mm <linux-mm@kvack.org>

On 03/29/2011 12:36 AM, James Bottomley wrote:
> Hi All,
>
> Since LSF is less than a week away, the programme committee put together
> a just in time preliminary agenda for LSF.  As you can see there is
> still plenty of empty space, which you can make suggestions

There have been a few patches upstream by people for who
page allocation latency is a concern.

It may be worthwhile to have a short discussion on what
we can do to keep page allocation (and direct reclaim?)
latencies down to a minimum, reducing the slowdown that
direct reclaim introduces on some workloads.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
