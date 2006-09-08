Date: Fri, 8 Sep 2006 12:06:16 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 1/2] own header file for struct page.
Message-Id: <20060908120616.db18c4a0.akpm@osdl.org>
In-Reply-To: <20060908183340.GA8421@osiris.ibm.com>
References: <20060908111716.GA6913@osiris.boeblingen.de.ibm.com>
	<20060908094616.48849a7a.akpm@osdl.org>
	<20060908183340.GA8421@osiris.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 8 Sep 2006 20:33:40 +0200
Heiko Carstens <heiko.carstens@de.ibm.com> wrote:

> > > +#ifndef CONFIG_DISCONTIGMEM
> > > +/* The array of struct pages - for discontigmem use pgdat->lmem_map */
> > > +extern struct page *mem_map;
> > > +#endif
> > 
> > Am surprised to see this declaration in this file.
> 
> Hmm... first I thought I could add the same declaration to asm-s390/pgtable.h.
> But then deciced against it, since I would just duplicate code.
> Any better idea where to put it?

dunno.  mmzone.h?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
