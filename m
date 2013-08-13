Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 381296B0034
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 17:35:05 -0400 (EDT)
Message-ID: <520AA687.3070303@sgi.com>
Date: Tue, 13 Aug 2013 16:35:03 -0500
From: Nathan Zimmer <nzimmer@sgi.com>
MIME-Version: 1.0
Subject: Re: [RFC v3 0/5] Transparent on-demand struct page initialization
 embedded in the buddy allocator
References: <1375465467-40488-1-git-send-email-nzimmer@sgi.com> <1376344480-156708-1-git-send-email-nzimmer@sgi.com> <CA+55aFwTQLexJkf67P0b7Z7cw8fePjdDSdA4SOkM+Jf+kBPYEA@mail.gmail.com> <520A6DFC.1070201@sgi.com> <CA+55aFwRHdQ_f6ryUU1yWkW1Qz8cG958jLZuyhd_YdOq4-rfRA@mail.gmail.com> <520A7514.9020008@sgi.com>
In-Reply-To: <520A7514.9020008@sgi.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Robin Holt <holt@sgi.com>, Rob Landley <rob@landley.net>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>

On 08/13/2013 01:04 PM, Mike Travis wrote:
>
> On 8/13/2013 10:51 AM, Linus Torvalds wrote:
>> by the time you can log in. And if it then takes another ten minutes
>> until you have the full 16TB initialized, and some things might be a
>> tad slower early on, does anybody really care?  The machine will be up
>> and running with plenty of memory, even if it may not be *all* the
>> memory yet.
> Before the patches adding memory took ~45 mins for 16TB and almost 2 hours
> for 32TB.  Adding it late sped up early boot but late insertion was still
> very slow, where the full 32TB was still not fully inserted after an hour.
> Doing it in parallel along with the memory hotplug lock per node, we got
> it down to the 10-15 minute range.
Yes but to get it to the 10-15 minute range I had to change an number of 
system locks.
The system_sleep, the memory_hotplug, zonelist_mutex and there was some 
general alteration
to various wmark routines.
Some of those fixes I don't know if they would stand up to proper 
scrutiny but were quick and dirty
hacks to allow for progress.

Nate

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
