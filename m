Subject: Re: Warning message when compiling ioremap.c
From: Phil Blundell <philb@gnu.org>
In-Reply-To: <48C5247A.1030801@evidence.eu.com>
References: <48BCED2A.6030109@evidence.eu.com>
	 <20080903140140.333bc137@doriath.conectiva>
	 <48C5247A.1030801@evidence.eu.com>
Content-Type: text/plain
Date: Mon, 08 Sep 2008 14:19:28 +0100
Message-Id: <1220879968.1250.1.camel@mill.internal.reciva.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Claudio Scordino <claudio@evidence.eu.com>
Cc: "Luiz Fernando N. Capitulino" <lcapitulino@mandriva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2008-09-08 at 15:11 +0200, Claudio Scordino wrote: 
> The need for the goto exists only if BUG() can return, and it doesn't, 
> so we can safely remove it as you suggested.

The structure of the original code (with the goto) is arranged so that
the code path is a straight line for the normal, non-bad case.  If you
want to remove the goto, you should wrap the condition in unlikely() so
as not to introduce another branch.

> Who's in charge of maintaining this piece of code? Should the patch
> in attachment be submitted to some specific person?

I guess you should send it to the linux-arm-kernel list.

p.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
