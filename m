Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E46556B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 00:10:57 -0400 (EDT)
Received: by fxm18 with SMTP id 18so6095240fxm.14
        for <linux-mm@kvack.org>; Mon, 23 May 2011 21:10:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTine2kobQA8TkmtiuXdKL=07NCo2vA@mail.gmail.com>
References: <20110520161816.dda6f1fd.sfr@canb.auug.org.au> <BANLkTimjzzqTS1fELmpb0UivqseLsYOfPw@mail.gmail.com>
 <BANLkTine2kobQA8TkmtiuXdKL=07NCo2vA@mail.gmail.com>
From: Mike Frysinger <vapier.adi@gmail.com>
Date: Tue, 24 May 2011 00:10:35 -0400
Message-ID: <BANLkTim-zRShhy49d7yn5WTJYzR6A2DtZQ@mail.gmail.com>
Subject: Re: linux-next: build failure after merge of the final tree
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Dipankar Sarma <dipankar@in.ibm.com>

On Tue, May 24, 2011 at 00:01, Linus Torvalds wrote:
> On Mon, May 23, 2011 at 7:06 PM, Mike Frysinger wrote:
>>
>> more failures:
>
> Is this blackfin or something?

let's go with "something" ...

> I did an allyesconfig with a special x86 patch that should have caught
> everything that didn't have the proper prefetch.h include, but non-x86
> drivers would have passed that.

the isp1362-hcd failure probably is before your
268bb0ce3e87872cb9290c322b0d35bce230d88f.  i think i was reading a log
that is a few days old (ive been traveling and am playing catch up
atm).  i'll refresh and see what's what still.

the common musb code only allows it to be built if the arch glue is
available, and there is no x86 glue.  so an allyesconfig on x86
wouldnt have picked up the failure.  it'll bomb though for any target
which does have the glue.
-mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
