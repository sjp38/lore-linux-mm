Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C957F6B006A
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 03:45:51 -0400 (EDT)
Date: Fri, 26 Jun 2009 10:48:48 +0300
From: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Subject: Re: kmemleak suggestion (long message)
Message-ID: <20090626074847.GA3451@localdomain.by>
References: <20090625221816.GA3480@localdomain.by>
 <20090626065923.GA14078@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090626065923.GA14078@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (06/26/09 08:59), Ingo Molnar wrote:
> Date: Fri, 26 Jun 2009 08:59:23 +0200
> From: Ingo Molnar <mingo@elte.hu>
> To: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
> Cc: Catalin Marinas <catalin.marinas@arm.com>,
> 	Pekka Enberg <penberg@cs.helsinki.fi>,
> 	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
> 	Andrew Morton <akpm@linux-foundation.org>,
> 	linux-kernel@vger.kernel.org, linux-mm@kvack.org
> Subject: Re: kmemleak suggestion (long message)
> User-Agent: Mutt/1.5.18 (2008-05-17)
> 
> 
> * Sergey Senozhatsky <sergey.senozhatsky@mail.by> wrote:
> 
> > Hello.
> > 
> > Currently kmemleak prints info about all objects. I guess 
> > sometimes kmemleak gives you more than you actually need.
> 
> It prints _a lot_ of info and spams the syslog. I lost crash info a 
> few days ago due to that: by the time i inspected a crashed machine 
> the tons of kmemleak output scrolled out the crash from the dmesg 
> buffer.
> 
> This is not acceptable.
> 
Agreed.

> Instead it should perhaps print _at most_ a single line every few 
> minutes, printing a summary about _how many_ leaked entries it 
> suspects, and should offer a /debug/mm/kmemleak style of file where 
> the entries can be read out from.
> 
> Ok?
> 
> 	Ingo
> 
Agreed.

	Sergey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
