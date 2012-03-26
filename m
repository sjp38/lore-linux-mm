Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id EEA5B6B004D
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 11:10:15 -0400 (EDT)
Received: by yhr47 with SMTP id 47so4940998yhr.14
        for <linux-mm@kvack.org>; Mon, 26 Mar 2012 08:10:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120326135609.GM1007@csn.ul.ie>
References: <20120324130353.48f2e4c8@kryten>
	<20120324102621.353114da@annuminas.surriel.com>
	<20120326093201.GL1007@csn.ul.ie>
	<CAOJsxLGcoxxdhe2sNmAbC2e5afnZm9960XxBjY+QoCoc0RRb2w@mail.gmail.com>
	<20120326135609.GM1007@csn.ul.ie>
Date: Mon, 26 Mar 2012 18:10:13 +0300
Message-ID: <CAOJsxLHEHQOQsn9p8v6cq6SKM-E39WAy=CeaY=EN8gb9P5LEKQ@mail.gmail.com>
Subject: Re: [PATCH] Re: kswapd stuck using 100% CPU
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Rik van Riel <riel@redhat.com>, Anton Blanchard <anton@samba.org>, aarcange@redhat.com, akpm@linux-foundation.org, hughd@google.com, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

Hi Mel,

On Mon, Mar 26, 2012 at 4:56 PM, Mel Gorman <mel@csn.ul.ie> wrote:
>> The API looks fragile and this patch isn't exactly making it any
>> better. Why don't we make compaction_suitable() return something other
>> than COMPACT_SKIPPED for !CONFIG_COMPACTION case?
>
> Returning COMPACT_PARTIAL or COMPACT_CONTINUE would confuse the check in
> should_continue_reclaim. A fourth return type could be added but an
> obvious name does not spring to mind that would end up being similar to
> just adding a CONFIG_COMPACTION check.

How about COMPACT_DISABLED?

The current API just doesn't make sense from practical point of view.
Anyone calling compaction_suitable() needs to do the COMPAT_BUILD
check first which is a non-obvious and error-prone API.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
