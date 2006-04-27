From: Andi Kleen <ak@suse.de>
Subject: Re: Lockless page cache test results
Date: Thu, 27 Apr 2006 08:15:18 +0200
References: <4t153d$r2dpi@azsmga001.ch.intel.com>
In-Reply-To: <4t153d$r2dpi@azsmga001.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200604270815.18575.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Jens Axboe' <axboe@suse.de>, 'Nick Piggin' <nickpiggin@yahoo.com.au>, linux-kernel@vger.kernel.org, 'Nick Piggin' <npiggin@suse.de>, 'Andrew Morton' <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 27 April 2006 07:39, Chen, Kenneth W wrote:
 
> (1) 2P Intel Xeon, 3.4 GHz/HT, 2M L2
> http://kernel-perf.sourceforge.net/splice/2P-3.4Ghz.png
> 
> (2) 4P Intel Xeon, 3.0 GHz/HT, 8M L3
> http://kernel-perf.sourceforge.net/splice/4P-3.0Ghz.png
> 
> (3) 4P Intel Xeon, 3.0 GHz/DC/HT, 2M L2 (per core)
> http://kernel-perf.sourceforge.net/splice/4P-3.0Ghz-DCHT.png
> 
> (4) everything on one graph:
> http://kernel-perf.sourceforge.net/splice/splice.png

Looks like a clear improvement for lockless unless I'm misreading the graphs.
(Can you please use different colors next time?)

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
