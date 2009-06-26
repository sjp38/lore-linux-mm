Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 395846B0062
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 04:13:14 -0400 (EDT)
Date: Fri, 26 Jun 2009 11:14:52 +0300
From: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Subject: Re: kmemleak suggestion (long message)
Message-ID: <20090626081452.GB3451@localdomain.by>
References: <20090625221816.GA3480@localdomain.by>
 <20090626065923.GA14078@elte.hu>
 <84144f020906260007u3e79086bv91900e487ba0fb50@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f020906260007u3e79086bv91900e487ba0fb50@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Ingo Molnar <mingo@elte.hu>, Catalin Marinas <catalin.marinas@arm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (06/26/09 10:07), Pekka Enberg wrote:
> > This is not acceptable.
> >
> > Instead it should perhaps print _at most_ a single line every few
> > minutes, printing a summary about _how many_ leaked entries it
> > suspects, and should offer a /debug/mm/kmemleak style of file where
> > the entries can be read out from.
> 
> Yup, makes tons of sense.
> 
>                                      Pekka
> 

Hello Pekka,
What do you about suggested ability to filter/block "unwanted" reports?
IMHO it makes sense.

	Sergey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
