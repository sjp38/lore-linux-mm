Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id EB88A6B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 16:37:04 -0400 (EDT)
Message-ID: <4F91C8EA.9060708@parallels.com>
Date: Sat, 21 Apr 2012 00:36:58 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] proc: Report PageAnon in last left bit of /proc/pid/pagemap
References: <4F91BC8A.9020503@parallels.com> <4F91C7E7.8060300@redhat.com>
In-Reply-To: <4F91C7E7.8060300@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>

On 04/21/2012 12:32 AM, Rik van Riel wrote:
> On 04/20/2012 03:44 PM, Pavel Emelyanov wrote:
> 
>> Andrew noticed, that the proc pagemap file solved 2 of 3 above issues -- it
>> reports whether a page is present or swapped and it doesn't report not
>> mapped page cache pages. But, it doesn't distinguish cow-ed file pages from
>> not cow-ed.
>>
>> I would like to make the last unused bit in this file to report whether the
>> page mapped into respective pte is PageAnon or not.
>>
>> Signed-off-by: Pavel Emelyanov<xemul@openvz.org>
> 
> Looks reasonable to me. I see you also report "special" pages
> as file pages, but since those cannot be migrated anyway that
> should be ok.

Yes, and all the anon-shared pages happen to be PM_FILE too :) But they can be
filtered with vma flags/prot, so I hoped it's OK to do it that way for simplicity.

> Acked-by: Rik van Riel <riel@redhat.com>
> 

Thanks,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
