Date: Wed, 30 Apr 2003 11:35:44 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: 2.5.68-mm3
Message-ID: <20030430183544.GB23891@kroah.com>
References: <20030429235959.3064d579.akpm@digeo.com> <1051696273.591.4.camel@teapot.felipe-alfaro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1051696273.591.4.camel@teapot.felipe-alfaro.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
Cc: Andrew Morton <akpm@digeo.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 30, 2003 at 11:51:13AM +0200, Felipe Alfaro Solana wrote:
> 
> drivers/pcmcia/cs.c: In function `pcmcia_register_socket':
> drivers/pcmcia/cs.c:361: `dev' undeclared (first use in this function)
> drivers/pcmcia/cs.c:361: (Each undeclared identifier is reported only
> once
> drivers/pcmcia/cs.c:361: for each function it appears in.)
> drivers/pcmcia/cs.c: At top level:
> drivers/pcmcia/cs.c:391: conflicting types for
> `pcmcia_unregister_socket'
> drivers/pcmcia/cs.c:306: previous declaration of
> `pcmcia_unregister_socket'
> make[4]: *** [drivers/pcmcia/cs.o] Error 1
> make[3]: *** [drivers/pcmcia] Error 2
> make[2]: *** [drivers] Error 2
> make[1]: *** [vmlinux] Error 2
> 
> Config file attached :-)

Does this also happen on the latest -bk tree?

thanks,

greg k-h
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
