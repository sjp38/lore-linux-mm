Date: Wed, 11 Jun 2003 02:27:00 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.70-mm8
Message-Id: <20030611022700.1ae8fd8b.akpm@digeo.com>
In-Reply-To: <3EE6F3B7.9040809@gts.it>
References: <20030611013325.355a6184.akpm@digeo.com>
	<3EE6F3B7.9040809@gts.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stefano Rivoir <s.rivoir@gts.it>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stefano Rivoir <s.rivoir@gts.it> wrote:
>
> Andrew Morton wrote:
> 
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.70/2.5.70-mm8/
> 
> arch/i386/kernel/setup.c: In function 'setup_early_printk':
> arch/i386/kernel/setup.c:919: error: invalid lvalue in unary '&'
> make[1]: *** [arch/i386/kernel/setup.o] Error 1
> 

That patch came from a person at IBM, where blissful unawareness of
single-processor machines is rampant :)

Thanks, will fix.


Meanwhile,  CONFIG_DEBUG_EARLY_PRINTK=n
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
