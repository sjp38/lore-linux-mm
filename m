Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 941DF6B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 05:41:51 -0400 (EDT)
Received: by fxm2 with SMTP id 2so2683245fxm.38
        for <linux-mm@kvack.org>; Mon, 29 Jun 2009 02:43:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090628173632.GA3890@localdomain.by>
References: <20090628173632.GA3890@localdomain.by>
Date: Mon, 29 Jun 2009 12:43:09 +0300
Message-ID: <84144f020906290243u7a362465p6b1f566257fa3239@mail.gmail.com>
Subject: Re: kmemleak hexdump proposal
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Cc: Catalin Marinas <catalin.marinas@arm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Sergey,

On Sun, Jun 28, 2009 at 8:36 PM, Sergey
Senozhatsky<sergey.senozhatsky@mail.by> wrote:
> What do you think about ability to 'watch' leaked region? (hex + ascii).
> (done via lib/hexdump.c)

What's your use case for this? I'm usually more interested in the
stack trace when there's a memory leak.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
