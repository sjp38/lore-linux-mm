Message-ID: <416E2B6F.5040803@yahoo.com.au>
Date: Thu, 14 Oct 2004 17:31:59 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Page cache write performance issue
References: <20041013054452.GB1618@frodo> <20041012231945.2aff9a00.akpm@osdl.org> <20041013063955.GA2079@frodo> <20041013000206.680132ad.akpm@osdl.org> <20041013172352.B4917536@wobbly.melbourne.sgi.com> <416CE423.3000607@cyberone.com.au> <20041013013941.49693816.akpm@osdl.org> <20041014005300.GA716@frodo> <20041013202041.2e7066af.akpm@osdl.org> <20041014071659.GB1768@frodo>
In-Reply-To: <20041014071659.GB1768@frodo>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nathan Scott <nathans@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, piggin@cyberone.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

Nathan Scott wrote:
> On Wed, Oct 13, 2004 at 08:20:41PM -0700, Andrew Morton wrote:
> 
>>Nathan Scott <nathans@sgi.com> wrote:
>>
>>> I just tried switching CONFIG_HIGHMEM off, and so running the
>>> machine with 512MB; then adjusted the test to write 256M into
>>> the page cache, again in 1K sequential chunks.  A similar mis-
>>> behaviour happens, though the numbers are slightly better (up
>>> from ~4 to ~6.5MB/sec).  Both ext2 and xfs see this.  When I
>>> drop the file size down to 128M with this kernel, I see good
>>> results again (as we'd expect).
>>
>>No such problem here, with
>>
>>	dd if=/dev/zero of=x bs=1k count=128k
>>
>>on a 256MB machine.  xfs and ext2.
> 
> 
> Yup, rebooted with mem=128M and on my box, & that crawls.
> Maybe its just this old hunk 'o junk, I suppose; odd that
> 2.6.8 was OK with this though.
> 

Just out of interest, can you get profiles and a few lines
of vmstat 1 from 2.6.8 and 2.6.9-rc, please?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
