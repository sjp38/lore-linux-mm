Subject: Re: [PATCH 2/2] move slab pages to the lru, for 2.5.27
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <Pine.LNX.4.44.0207221520301.14311-100000@loke.as.arizona.edu>
References: <Pine.LNX.4.44.0207221520301.14311-100000@loke.as.arizona.edu>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 23 Jul 2002 08:31:05 -0600
Message-Id: <1027434665.12588.78.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Craig Kulesa <ckulesa@as.arizona.edu>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ed Tomlinson <tomlins@cam.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2002-07-22 at 16:36, Craig Kulesa wrote:
> 
> On Mon, 22 Jul 2002, William Lee Irwin III wrote:
> 
> > The pte_chain mempool was ridiculously huge and the use of mempool for
> > this at all was in error.
> 
[snipped]
> 
> in dquot.c.  It'll be tested and fixed on the next go. :)

1st the good news.  The 2.5.27-rmap-2b-dqcache patch fixed the compile
problem with CONFIG_QUOTA=y.

Then, I patched in 2.5.27-rmap-3-slaballoc from Craig's site and the
test machine got much further in the boot, but hung up here:

Starting cron daemon
/etc/rc.d/rc3.d/S50inet: fork: Cannot allocate memory

Sorry, no further information was available.

Steven

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
