Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 27D166B0136
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 23:28:53 -0400 (EDT)
Message-ID: <4E000FED.7050506@redhat.com>
Date: Tue, 21 Jun 2011 11:28:45 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: completely disable THP by transparent_hugepage=never
References: <1308587683-2555-1-git-send-email-amwang@redhat.com> <20110620165844.GA9396@suse.de> <4DFF7E3B.1040404@redhat.com> <4DFF7F0A.8090604@redhat.com> <4DFF8106.8090702@redhat.com> <4DFF8327.1090203@redhat.com> <4DFF84BB.3050209@redhat.com> <4DFF8848.2060802@redhat.com>
In-Reply-To: <4DFF8848.2060802@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

ao? 2011a1'06ae??21ae?JPY 01:50, Rik van Riel a??e??:
> On 06/20/2011 01:34 PM, Cong Wang wrote:
>
>> Even if it is really 10K, why not save it since it doesn't
>> much effort to make this. ;) Not only memory, but also time,
>> this could also save a little time to initialize the kernel.
>>
>> For me, the more serious thing is the logic, there is
>> no way to totally disable it as long as I have THP in .config
>> currently. This is why I said the design is broken.
>
> There are many things you cannot totally disable as long
> as they are enabled in the .config. Think about things
> like swap, or tmpfs - neither of which you are going to
> use in the crashdump kernel.

Sure, things like CONFIG_KEXEC can never be disabled
without changing .config too, they are designed like this.

Some features _do_ only mean to be disabled only
by Kconfig, some syscalls are indeed good examples here,
but some features don't. THP is one of them, because features
like this can be tuned dynamically.

>
> I believe we need to keep the kernel optimized for common
> use and convenience.
>
> Crashdump is very much a corner case. Yes, using less
> memory in crashdump is worthwhile, but lets face it -
> the big memory user there is likely to be the struct page
> array, with everything else down in the noise...

For the 128M case, only the struct page's of the 128M is
constructed in the second kernel, which unlikely to be a big user.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
