Date: Sat, 29 Apr 2006 00:10:41 +1000
From: David Chinner <dgc@sgi.com>
Subject: Re: Lockless page cache test results
Message-ID: <20060428141041.GB4657648@melbourne.sgi.com>
References: <20060426135310.GB5083@suse.de> <20060426095511.0cc7a3f9.akpm@osdl.org> <20060426174235.GC5002@suse.de> <20060426111054.2b4f1736.akpm@osdl.org> <Pine.LNX.4.64.0604261130450.19587@schroedinger.engr.sgi.com> <20060426114737.239806a2.akpm@osdl.org> <20060426184945.GL5002@suse.de> <Pine.LNX.4.64.0604261330310.20897@schroedinger.engr.sgi.com> <20060428140146.GA4657648@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060428140146.GA4657648@melbourne.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Christoph Lameter <clameter@sgi.com>, Jens Axboe <axboe@suse.de>, Andrew Morton <akpm@osdl.org>, npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Apr 29, 2006 at 12:01:47AM +1000, David Chinner wrote:
> 
> 
> Loads   Type    blksize count   av_time    tput    usr%   sys%   intr%
> -----   ----    ------- -----   ------- -------    ----   ----   -----

Sorry, I forgot units:              (s)   (MiB/s)      (cpu usage)

>   1      read   256.00K 256.00K   82.92  789.59    1.80  215.40   18.40
>   2      read   256.00K 256.00K   53.97 1191.56    2.10  389.40   22.60
>   4      read   256.00K 256.00K   37.83 1724.63    2.20  776.00   29.30
>   8      read   256.00K 256.00K   52.57 1213.63    2.20 1423.60   24.30
>   16     read   256.00K 256.00K   60.05 1057.03    1.90 1951.10   24.30
>   32     read   256.00K 256.00K   82.13  744.73    2.00 2277.50   18.60
>                                         ^^^^^^^         ^^^^^^^

And the reader is dd to /dev/null.

Cheers,

Dave.
-- 
Dave Chinner
R&D Software Enginner
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
