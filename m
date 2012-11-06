Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 4FA726B0044
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 20:49:43 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id rq2so7741pbb.14
        for <linux-mm@kvack.org>; Mon, 05 Nov 2012 17:49:42 -0800 (PST)
Date: Tue, 6 Nov 2012 10:49:32 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC v2] Support volatile range for anon vma
Message-ID: <20121106014932.GA4623@barrios>
References: <1351560594-18366-1-git-send-email-minchan@kernel.org>
 <20121031143524.0509665d.akpm@linux-foundation.org>
 <CAPM31RKm89s6PaAnfySUD-f+eGdoZP6=9DHy58tx_4Zi8Z9WPQ@mail.gmail.com>
 <CAHGf_=om34CQoPqgmVE5v8oVxntaJQ-bvFeEPMnfe_R+uvxqrQ@mail.gmail.com>
 <20121105235443.GA27718@dev3310.snc6.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121105235443.GA27718@dev3310.snc6.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun Sharma <asharma@fb.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Paul Turner <pjt@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Stultz <john.stultz@linaro.org>, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, sanjay@google.com, David Rientjes <rientjes@google.com>

Hello,

On Mon, Nov 05, 2012 at 03:54:43PM -0800, Arun Sharma wrote:
> On Wed, Oct 31, 2012 at 06:56:05PM -0400, KOSAKI Motohiro wrote:
> > glibc malloc discard freed memory by using MADV_DONTNEED
> > as tcmalloc. and it is often a source of large performance decrease.
> > because of MADV_DONTNEED discard memory immediately and
> > right after malloc() call fall into page fault and pagesize memset() path.
> > then, using DONTNEED increased zero fill and cache miss rate.
> 
> The memcg based solution that I posted a few months ago is working well
> for us. We see significantly less cpu in zero'ing pages.
> 
> Not everyone was comfortable with the security implications of recycling
> pages between processes in a memcg, although it was disabled by default
> and had to be explicitly opted-in.
> 
> Also, memory allocators have a second motivation in using madvise: to
> create virtually contiguous regions of memory from a fragmented address 
> space, without increasing the RSS.

I don't get it. How do we create contiguos region by madvise?
Just out of curiosity.
Could you elaborate that use case? :)

> 
>  -Arun
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind Regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
