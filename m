Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5DC816B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 06:41:01 -0400 (EDT)
Subject: Re: kmemleak hexdump proposal
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <1246271880.21450.13.camel@pc1117.cambridge.arm.com>
References: <20090628173632.GA3890@localdomain.by>
	 <84144f020906290243u7a362465p6b1f566257fa3239@mail.gmail.com>
	 <20090629101917.GA3093@localdomain.by>
	 <1246270774.6364.9.camel@penberg-laptop>
	 <1246271880.21450.13.camel@pc1117.cambridge.arm.com>
Date: Mon, 29 Jun 2009 13:42:15 +0300
Message-Id: <1246272135.6364.10.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@mail.by>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Catalin,

On Mon, 2009-06-29 at 11:38 +0100, Catalin Marinas wrote:
> Anyway, I may not include it before the next merging window (when is
> actually the best time for new features). Currently, my main focus is on
> reducing the false positives.

Yes, this new feature shouldn't go into 2.6.31. That said, you _do_ want
to include it in linux-next now if you're interested in pushing it to
2.6.32.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
