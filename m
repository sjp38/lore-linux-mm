Date: Sat, 15 Jan 2005 20:40:18 +0800
From: Bernard Blackham <bernard@blackham.com.au>
Subject: Re: Odd kswapd behaviour after suspending in 2.6.11-rc1
Message-ID: <20050115124018.GA24653@blackham.com.au>
References: <20050113061401.GA7404@blackham.com.au> <41E61479.5040704@yahoo.com.au> <20050113085626.GA5374@blackham.com.au> <20050113101426.GA4883@blackham.com.au> <41E8ED89.8090306@yahoo.com.au> <1105785254.13918.4.camel@desktop.cunninghams> <41E8F313.4030102@yahoo.com.au> <1105786115.13918.9.camel@desktop.cunninghams> <41E8F7F7.1010908@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <41E8F7F7.1010908@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: ncunningham@linuxmail.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, Jan 15, 2005 at 10:01:11PM +1100, Nick Piggin wrote:
> Also, Bernard, can you try running with the following patch and
> see what output it gives when you reproduce the problem?

On resuming:

*** Cleaning up...
kswapd: balance_pgdat, order = 10
Please include the following information in bug reports:
- SUSPEND core   : 2.1.5.13
- Kernel Version : 2.6.11-rc1
- Compiler vers. : 3.4
- Modules loaded :
- Attempt number : 3
- Pageset sizes  : 3561 (3561 low) and 60538 (60538 low).
- Parameters     : 0 2049 0 9 0 5
- Calculations   : Image size: 64103. Ram to suspend: 652.
- Limits         : 65520 pages RAM. Initial boot: 63252.
- Overall expected compression percentage: 0.
- LZF Compressor enabled.
  Compressed 262549504 bytes into 28599419 (89 percent compression).
- Swapwriter active.
- Swap available for image: 123165 pages.
- Debugging compiled in.
- Max extents used: 44 extents in 1 pages.
- I/O speed: Write 59 MB/s, Read 52 MB/s.

Bernard.

-- 
 Bernard Blackham <bernard at blackham dot com dot au>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
