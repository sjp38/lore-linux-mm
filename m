Subject: Re: 2.6.1-rc1-mm2
From: Dax Kelson <dax@gurulabs.com>
In-Reply-To: <20040105002056.43f423b1.akpm@osdl.org>
References: <20040105002056.43f423b1.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1073294151.10221.792.camel@mentor.gurulabs.com>
Mime-Version: 1.0
Date: Mon, 05 Jan 2004 02:15:51 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2004-01-05 at 01:20, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.1-rc1/2.6.1-rc1-mm2
> 
> 
> Many new fixes, all over the place.

I'm excited about the included laptop-mode patch. I've had great results
with the 2.4 patch in the Fedora kernel.

build error:

  CC [M]  drivers/char/watchdog/amd7xx_tco.o
drivers/char/watchdog/amd7xx_tco.c: In function `amdtco_fop_write':
drivers/char/watchdog/amd7xx_tco.c:257: error: syntax error before "i"
drivers/char/watchdog/amd7xx_tco.c:257: error: `i' undeclared (first use in this function)
drivers/char/watchdog/amd7xx_tco.c:257: error: (Each undeclared identifier is reported only once
drivers/char/watchdog/amd7xx_tco.c:257: error: for each function it appears in.)
drivers/char/watchdog/amd7xx_tco.c:258: warning: ISO C90 forbids mixed declarations and code
drivers/char/watchdog/amd7xx_tco.c:262: warning: type defaults to `int' in declaration of `type name'
drivers/char/watchdog/amd7xx_tco.c: At top level:
drivers/char/watchdog/amd7xx_tco.c:272: error: syntax error before "return"
make[3]: *** [drivers/char/watchdog/amd7xx_tco.o] Error 1
make[2]: *** [drivers/char/watchdog] Error 2
make[1]: *** [drivers/char] Error 2
make: *** [drivers] Error 2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
