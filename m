Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 9845C6B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 16:32:45 -0400 (EDT)
Message-ID: <4F91C7E7.8060300@redhat.com>
Date: Fri, 20 Apr 2012 16:32:39 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] proc: Report PageAnon in last left bit of /proc/pid/pagemap
References: <4F91BC8A.9020503@parallels.com>
In-Reply-To: <4F91BC8A.9020503@parallels.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>

On 04/20/2012 03:44 PM, Pavel Emelyanov wrote:

> Andrew noticed, that the proc pagemap file solved 2 of 3 above issues -- it
> reports whether a page is present or swapped and it doesn't report not
> mapped page cache pages. But, it doesn't distinguish cow-ed file pages from
> not cow-ed.
>
> I would like to make the last unused bit in this file to report whether the
> page mapped into respective pte is PageAnon or not.
>
> Signed-off-by: Pavel Emelyanov<xemul@openvz.org>

Looks reasonable to me. I see you also report "special" pages
as file pages, but since those cannot be migrated anyway that
should be ok.

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
