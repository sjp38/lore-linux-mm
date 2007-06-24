From: Neil Brown <neilb@suse.de>
Date: Mon, 25 Jun 2007 09:01:32 +1000
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18046.63436.472085.535177@notabene.brown>
Subject: Re: [patch 1/3] add the fsblock layer
In-Reply-To: message from Nick Piggin on Sunday June 24
References: <20070624014528.GA17609@wotan.suse.de>
	<20070624014613.GB17609@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sunday June 24, npiggin@suse.de wrote:
>  
> +#define PG_blocks		20	/* Page has block mappings */
> +

I've only had a very quick look, but this line looks *very* wrong.
You should be using PG_private.

There should never be any confusion about whether ->private has
buffers or blocks attached as the only routines that ever look in
->private are address_space operations  (or should be.  I think 'NULL'
is sometimes special cased, as in try_to_release_page.  It would be
good to do some preliminary work and tidy all that up).

Why do you think you need PG_blocks?

NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
