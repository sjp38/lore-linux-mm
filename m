Date: Sat, 19 Jul 2003 21:30:38 -0700
From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.6.0-test1-mm2
Message-Id: <20030719213038.5c719bbe.davem@redhat.com>
In-Reply-To: <20030719212715.42be9277.akpm@osdl.org>
References: <20030719174350.7dd8ad59.akpm@osdl.org>
	<20030720024102.GA18576@triplehelix.org>
	<20030719212715.42be9277.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: joshk@triplehelix.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 19 Jul 2003 21:27:15 -0700
Andrew Morton <akpm@osdl.org> wrote:

> Joshua Kwan <joshk@triplehelix.org> wrote:
> >   /* References to section boundaries */
> >  -extern char _text, _etext, _edata, __bss_start, _end;
> >  +extern char _text[], _etext[], _edata[], __bss_start[], _end[];
> 
> No, the declaration simply needs to be deleted; it is already provided by
> asm/sections.h.
> 
> Incorrectly, I believe.  Those symbols are conventionally "extern int".

True, from some perspective.

But you have to admit the pointer math gets real ugly if we declare
them in that way. :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
