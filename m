Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id D2D166B002B
	for <linux-mm@kvack.org>; Tue, 18 Dec 2012 13:28:31 -0500 (EST)
Message-ID: <50D0B5A2.2010707@fb.com>
Date: Tue, 18 Dec 2012 10:27:46 -0800
From: Arun Sharma <asharma@fb.com>
MIME-Version: 1.0
Subject: Re: [RFC v4 0/3] Support volatile for anonymous range
References: <1355813274-571-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1355813274-571-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, sanjay@google.com, Paul Turner <pjt@google.com>, David Rientjes <rientjes@google.com>, John Stultz <john.stultz@linaro.org>, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 12/17/12 10:47 PM, Minchan Kim wrote:

> I hope more inputs from user-space allocator people and test patch
> with their allocator because it might need design change of arena
> management for getting real vaule.

jemalloc knows how to handle MADV_FREE on platforms that support it. 
This looks similar (we'll need a SIGBUS handler that does the right 
thing = zero the page + mark it as non-volatile in the common case).

All of this of course assumes that apps madvise the kernel through APIs 
exposed by the malloc implementation - not via a raw syscall.

In other words, some new user space code needs to be written to test 
this out fully. Sounds feasible though.

  -Arun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
