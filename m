Date: Wed, 16 Jul 2003 10:21:41 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.0-test1-mm1
Message-Id: <20030716102141.69d9c3cb.akpm@osdl.org>
In-Reply-To: <1058368072.1636.2.camel@spc9.esa.lanl.gov>
References: <20030715225608.0d3bff77.akpm@osdl.org>
	<20030716061642.GA4032@triplehelix.org>
	<20030715232233.7d187f0e.akpm@osdl.org>
	<1058368072.1636.2.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Cole <elenstev@mesatop.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Steven Cole <elenstev@mesatop.com> wrote:
>
> drivers/eisa/eisa-bus.c:26: warning: padding struct size to alignment boundary
> make[2]: *** [drivers/eisa/eisa-bus.o] Error 1
> make[1]: *** [drivers/eisa] Error 2
> make: *** [drivers] Error 2
> make: *** Waiting for unfinished jobs....
>   CC      fs/ext3/balloc.o
> 
> Reverting wpadded.patch allowed -mm1 to build with CONFIG_EISA.

Yes, some smarty added -Werror to drivers/eisa/Makefile.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
