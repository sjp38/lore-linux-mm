Subject: Re: [PATCH] (1/2) reverse mapping VM for 2.5.23 (rmap-13b)
From: Steven Cole <scole@lanl.gov>
In-Reply-To: <Pine.LNX.4.44.0206181340380.3031-100000@loke.as.arizona.edu>
References: <Pine.LNX.4.44.0206181340380.3031-100000@loke.as.arizona.edu>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 19 Jun 2002 13:04:52 -0600
Message-Id: <1024513492.13955.13.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Craig Kulesa <ckulesa@as.arizona.edu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2002-06-19 at 05:18, Craig Kulesa wrote:
> 
> 
> Where:  http://loke.as.arizona.edu/~ckulesa/kernel/rmap-vm/
> 
> This patch implements Rik van Riel's patches for a reverse mapping VM 
> atop the 2.5.23 kernel infrastructure.  The principal sticky bits in 
> the port are correct interoperability with Andrew Morton's patches to 
> cleanup and extend the writeback and readahead code, among other things.  
> This patch reinstates Rik's (active, inactive dirty, inactive clean) 
> LRU list logic with the rmap information used for proper selection of pages 
> for eviction and better page aging.  It seems to do a pretty good job even 
> for a first porting attempt.  A simple, indicative test suite on a 192 MB 
> PII machine (loading a large image in GIMP, loading other applications, 
> heightening memory load to moderate swapout, then going back and 
> manipulating the original Gimp image to test page aging, then closing all 
> apps to the starting configuration) shows the following:
> 
> 2.5.22 vanilla:
> Total kernel swapouts during test = 29068 kB
> Total kernel swapins during test  = 16480 kB
> Elapsed time for test: 141 seconds
> 
> 2.5.23-rmap13b:
> Total kernel swapouts during test = 40696 kB
> Total kernel swapins during test  =   380 kB
> Elapsed time for test: 133 seconds
> 
> Although rmap's page_launder evicts a ton of pages under load, it seems to 
> swap the 'right' pages, as it doesn't need to swap them back in again.
> This is a good sign.  [recent 2.4-aa work pretty nicely too]
> 
> Various details for the curious or bored:
> 
> 	- Tested:   UP, 16 MB < mem < 256 MB, x86 arch. 
> 	  Untested: SMP, highmem, other archs. 
                    ^^^
I tried to boot 2.5.23-rmap13b on a dual PIII without success.

	Freeing unused kernel memory: 252k freed
hung here with CONFIG_SMP=y
	Adding 1052248k swap on /dev/sda6.  Priority:0 extents:1
	Adding 1052248k swap on /dev/sdb1.  Priority:0 extents:1

The above is the edited dmesg output from booting 2.5.23-rmap13b as an
UP kernel, which successfully booted on the same 2-way box.

Steven

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
