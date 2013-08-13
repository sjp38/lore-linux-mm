Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 5DE8E6B0032
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 14:04:07 -0400 (EDT)
Message-ID: <520A7514.9020008@sgi.com>
Date: Tue, 13 Aug 2013 11:04:04 -0700
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [RFC v3 0/5] Transparent on-demand struct page initialization
 embedded in the buddy allocator
References: <1375465467-40488-1-git-send-email-nzimmer@sgi.com> <1376344480-156708-1-git-send-email-nzimmer@sgi.com> <CA+55aFwTQLexJkf67P0b7Z7cw8fePjdDSdA4SOkM+Jf+kBPYEA@mail.gmail.com> <520A6DFC.1070201@sgi.com> <CA+55aFwRHdQ_f6ryUU1yWkW1Qz8cG958jLZuyhd_YdOq4-rfRA@mail.gmail.com>
In-Reply-To: <CA+55aFwRHdQ_f6ryUU1yWkW1Qz8cG958jLZuyhd_YdOq4-rfRA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Robin Holt <holt@sgi.com>, Rob Landley <rob@landley.net>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>



On 8/13/2013 10:51 AM, Linus Torvalds wrote:
> by the time you can log in. And if it then takes another ten minutes
> until you have the full 16TB initialized, and some things might be a
> tad slower early on, does anybody really care?  The machine will be up
> and running with plenty of memory, even if it may not be *all* the
> memory yet.

Before the patches adding memory took ~45 mins for 16TB and almost 2 hours
for 32TB.  Adding it late sped up early boot but late insertion was still
very slow, where the full 32TB was still not fully inserted after an hour.
Doing it in parallel along with the memory hotplug lock per node, we got
it down to the 10-15 minute range.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
