Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 843556B0032
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 16:37:59 -0400 (EDT)
Message-ID: <520A9924.7050301@sgi.com>
Date: Tue, 13 Aug 2013 13:37:56 -0700
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [RFC v3 0/5] Transparent on-demand struct page initialization
 embedded in the buddy allocator
References: <1375465467-40488-1-git-send-email-nzimmer@sgi.com> <1376344480-156708-1-git-send-email-nzimmer@sgi.com> <CA+55aFwTQLexJkf67P0b7Z7cw8fePjdDSdA4SOkM+Jf+kBPYEA@mail.gmail.com> <520A6DFC.1070201@sgi.com> <CA+55aFwRHdQ_f6ryUU1yWkW1Qz8cG958jLZuyhd_YdOq4-rfRA@mail.gmail.com> <520A7514.9020008@sgi.com> <520A83B0.40607@sgi.com> <CAE9FiQXdHWEF9aTQtTa8AjM8BTUZWg6TSUebqBr9aT8JL58c8A@mail.gmail.com>
In-Reply-To: <CAE9FiQXdHWEF9aTQtTa8AjM8BTUZWg6TSUebqBr9aT8JL58c8A@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Nathan Zimmer <nzimmer@sgi.com>, Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Robin Holt <holt@sgi.com>, Rob Landley <rob@landley.net>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Mel Gorman <mgorman@suse.de>



On 8/13/2013 1:24 PM, Yinghai Lu wrote:
>> > FYI, the system at this time had 128 nodes each with 256GB of memory.
>> > About 252GB was inserted into the absent list from nodes 1 .. 126.
>> > Memory on nodes 0 and 128 was left fully present.

Actually, I was corrected, it was 256 nodes with 128GB (8 * 16GB dimms -
which are just now coming out.)  So there were 254 concurrent initialization
processes running.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
