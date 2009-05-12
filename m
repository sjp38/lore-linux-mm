Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 63E0D6B009E
	for <linux-mm@kvack.org>; Tue, 12 May 2009 13:39:48 -0400 (EDT)
Message-ID: <4A09B46D.9010705@redhat.com>
Date: Tue, 12 May 2009 13:39:57 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] vmscan: protect a fraction of file backed mapped
 pages from reclaim
References: <20090508125859.210a2a25.akpm@linux-foundation.org> <20090512025246.GC7518@localhost> <20090512120002.D616.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0905121650090.14226@qirst.com> <4A09AC91.4060506@redhat.com> <alpine.DEB.1.10.0905121718040.24066@qirst.com>
In-Reply-To: <alpine.DEB.1.10.0905121718040.24066@qirst.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Tue, 12 May 2009, Rik van Riel wrote:
> 
>> The patch that only allows active file pages to be deactivated
>> if the active file LRU is larger than the inactive file LRU should
>> protect the working set from being evicted due to streaming IO.
> 
> Streaming I/O means access once? 

Yeah, "used-once pages" would be a better criteria, since
you could go through a gigantic set of used-once pages without
doing linear IO.

I expect that some databases might do that.

> What exactly are the criteria for a page
> to be part of streaming I/O? AFAICT the definition is more dependent on
> the software running than on a certain usage pattern discernible to the
> VM. Software may after all perform multiple scans over a stream of data or
> go back to prior locations in the file.


-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
