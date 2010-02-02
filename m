Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 121BA6B0096
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 15:00:40 -0500 (EST)
Date: Tue, 2 Feb 2010 11:59:03 -0800 (PST)
From: david@lang.hm
Subject: Re: [PATCH 10/11] readahead: dont do start-of-file readahead after
 lseek()
In-Reply-To: <alpine.LFD.2.00.1002021111240.3664@localhost.localdomain>
Message-ID: <alpine.DEB.2.00.1002021157280.3707@asgard.lang.hm>
References: <20100202152835.683907822@intel.com> <20100202153317.644170708@intel.com> <20100202181321.GB75577@dspnet.fr.eu.org> <alpine.LFD.2.00.1002021037110.3664@localhost.localdomain> <20100202184831.GD75577@dspnet.fr.eu.org>
 <alpine.LFD.2.00.1002021111240.3664@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Olivier Galibert <galibert@pobox.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2 Feb 2010, Linus Torvalds wrote:

> Rememebr: read-ahead is about filling the empty IO spaces _between_ reads,
> and turning many smaller reads into one bigger one. If you only have a
> single big read, read-ahead cannot help.
>
> Also, keep in mind that read-ahead is not always a win. It can be a huge
> loss too. Which is why we have _heuristics_. They fundamentally cannot
> catch every case, but what they aim for is to do a good job on average.

as a note from the field, I just had an application that needed to be 
changed because it did excessive read-ahead. it turned a 2 min reporting 
run into a 20 min reporting run because for this report the access was 
really random and the app forced large read-ahead.

David Lang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
