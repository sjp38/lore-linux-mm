Subject: Re: 2.5.68-mm3
From: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
In-Reply-To: <20030430183544.GB23891@kroah.com>
References: <20030429235959.3064d579.akpm@digeo.com>
	 <1051696273.591.4.camel@teapot.felipe-alfaro.com>
	 <20030430183544.GB23891@kroah.com>
Content-Type: text/plain
Message-Id: <1051743488.2661.1.camel@teapot.felipe-alfaro.com>
Mime-Version: 1.0
Date: 01 May 2003 00:58:09 +0200
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Greg KH <greg@kroah.com>
Cc: Andrew Morton <akpm@digeo.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2003-04-30 at 20:35, Greg KH wrote:
> On Wed, Apr 30, 2003 at 11:51:13AM +0200, Felipe Alfaro Solana wrote:
> > 
> > drivers/pcmcia/cs.c: In function `pcmcia_register_socket':
> > drivers/pcmcia/cs.c:361: `dev' undeclared (first use in this function)
> > drivers/pcmcia/cs.c:361: (Each undeclared identifier is reported only
> > once
> > drivers/pcmcia/cs.c:361: for each function it appears in.)
> > drivers/pcmcia/cs.c: At top level:
> > drivers/pcmcia/cs.c:391: conflicting types for
> > `pcmcia_unregister_socket'
> > drivers/pcmcia/cs.c:306: previous declaration of
> > `pcmcia_unregister_socket'
> > make[4]: *** [drivers/pcmcia/cs.o] Error 1
> > make[3]: *** [drivers/pcmcia] Error 2
> > make[2]: *** [drivers] Error 2
> > make[1]: *** [vmlinux] Error 2
> > 
> > Config file attached :-)
> 
> Does this also happen on the latest -bk tree?

Seems to be fixed in 2.5.68-bk10...
-- 
Please AVOID sending me WORD, EXCEL or POWERPOINT attachments.
See http://www.fsf.org/philosophy/no-word-attachments.html
Linux Registered User #287198

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
