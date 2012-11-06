Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id E18B46B0044
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 21:07:12 -0500 (EST)
Message-ID: <50987004.1000003@fb.com>
Date: Mon, 5 Nov 2012 18:03:48 -0800
From: Arun Sharma <asharma@fb.com>
MIME-Version: 1.0
Subject: Re: [RFC v2] Support volatile range for anon vma
References: <1351560594-18366-1-git-send-email-minchan@kernel.org> <20121031143524.0509665d.akpm@linux-foundation.org> <CAPM31RKm89s6PaAnfySUD-f+eGdoZP6=9DHy58tx_4Zi8Z9WPQ@mail.gmail.com> <CAHGf_=om34CQoPqgmVE5v8oVxntaJQ-bvFeEPMnfe_R+uvxqrQ@mail.gmail.com> <20121105235443.GA27718@dev3310.snc6.facebook.com> <20121106014932.GA4623@barrios>
In-Reply-To: <20121106014932.GA4623@barrios>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Paul Turner <pjt@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Stultz <john.stultz@linaro.org>, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, sanjay@google.com, David Rientjes <rientjes@google.com>

On 11/5/12 5:49 PM, Minchan Kim wrote:

>> Also, memory allocators have a second motivation in using madvise: to
>> create virtually contiguous regions of memory from a fragmented address
>> space, without increasing the RSS.
>
> I don't get it. How do we create contiguos region by madvise?
> Just out of curiosity.
> Could you elaborate that use case? :)

By using a new anonymous map and faulting pages in.

The fragmented virtual memory is released via MADV_DONTNEED and if the 
malloc/free activity on the system is dominated by one process, chances 
are that the newly faulted in page is the one released by the same 
process :)

The net effect is that physical pages within a single address space are 
rearranged so larger allocations can be satisfied.

  -Arun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
