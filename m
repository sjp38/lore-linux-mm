Date: Sat, 19 Jul 2003 21:27:15 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.0-test1-mm2
Message-Id: <20030719212715.42be9277.akpm@osdl.org>
In-Reply-To: <20030720024102.GA18576@triplehelix.org>
References: <20030719174350.7dd8ad59.akpm@osdl.org>
	<20030720024102.GA18576@triplehelix.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joshua Kwan <joshk@triplehelix.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Joshua Kwan <joshk@triplehelix.org> wrote:
>
>  2.6.0-test1-mm2 requires attached patch to build with software suspend.
> ...
>   
>   /* References to section boundaries */
>  -extern char _text, _etext, _edata, __bss_start, _end;
>  +extern char _text[], _etext[], _edata[], __bss_start[], _end[];

No, the declaration simply needs to be deleted; it is already provided by
asm/sections.h.

Incorrectly, I believe.  Those symbols are conventionally "extern int".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
