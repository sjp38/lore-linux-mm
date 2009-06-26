Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id AAC716B005D
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 04:17:22 -0400 (EDT)
Subject: Re: kmemleak suggestion (long message)
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20090626081452.GB3451@localdomain.by>
References: <20090625221816.GA3480@localdomain.by>
	 <20090626065923.GA14078@elte.hu>
	 <84144f020906260007u3e79086bv91900e487ba0fb50@mail.gmail.com>
	 <20090626081452.GB3451@localdomain.by>
Date: Fri, 26 Jun 2009 11:17:50 +0300
Message-Id: <1246004270.27533.16.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Cc: Ingo Molnar <mingo@elte.hu>, Catalin Marinas <catalin.marinas@arm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Sergey,

On (06/26/09 10:07), Pekka Enberg wrote:
> > > This is not acceptable.
> > >
> > > Instead it should perhaps print _at most_ a single line every few
> > > minutes, printing a summary about _how many_ leaked entries it
> > > suspects, and should offer a /debug/mm/kmemleak style of file where
> > > the entries can be read out from.
> > 
> > Yup, makes tons of sense.

On Fri, 2009-06-26 at 11:14 +0300, Sergey Senozhatsky wrote:
> What do you about suggested ability to filter/block "unwanted" reports?
> IMHO it makes sense.

Well, the thing is, I am not sure it's needed if we implement Ingo's
suggestion. After all, syslog is no longer spammed very hard and you can
do all the filtering in userspace when you read /debug/mm/kmemleak file,
no?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
