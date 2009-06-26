Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 25FBA6B004D
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 03:07:29 -0400 (EDT)
Received: by fxm2 with SMTP id 2so959242fxm.38
        for <linux-mm@kvack.org>; Fri, 26 Jun 2009 00:07:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090626065923.GA14078@elte.hu>
References: <20090625221816.GA3480@localdomain.by>
	 <20090626065923.GA14078@elte.hu>
Date: Fri, 26 Jun 2009 10:07:39 +0300
Message-ID: <84144f020906260007u3e79086bv91900e487ba0fb50@mail.gmail.com>
Subject: Re: kmemleak suggestion (long message)
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Sergey Senozhatsky <sergey.senozhatsky@mail.by>, Catalin Marinas <catalin.marinas@arm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Ingo,

* Sergey Senozhatsky <sergey.senozhatsky@mail.by> wrote:
>> Currently kmemleak prints info about all objects. I guess
>> sometimes kmemleak gives you more than you actually need.

On Fri, Jun 26, 2009 at 9:59 AM, Ingo Molnar<mingo@elte.hu> wrote:
> It prints _a lot_ of info and spams the syslog. I lost crash info a
> few days ago due to that: by the time i inspected a crashed machine
> the tons of kmemleak output scrolled out the crash from the dmesg
> buffer.
>
> This is not acceptable.
>
> Instead it should perhaps print _at most_ a single line every few
> minutes, printing a summary about _how many_ leaked entries it
> suspects, and should offer a /debug/mm/kmemleak style of file where
> the entries can be read out from.

Yup, makes tons of sense.

                                     Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
