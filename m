Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id F30506B0012
	for <linux-mm@kvack.org>; Tue, 24 May 2011 00:02:33 -0400 (EDT)
Received: from mail-ey0-f169.google.com (mail-ey0-f169.google.com [209.85.215.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p4O422dL012878
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Mon, 23 May 2011 21:02:03 -0700
Received: by eyd9 with SMTP id 9so2952473eyd.14
        for <linux-mm@kvack.org>; Mon, 23 May 2011 21:01:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTimjzzqTS1fELmpb0UivqseLsYOfPw@mail.gmail.com>
References: <20110520161816.dda6f1fd.sfr@canb.auug.org.au> <BANLkTimjzzqTS1fELmpb0UivqseLsYOfPw@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 23 May 2011 21:01:39 -0700
Message-ID: <BANLkTine2kobQA8TkmtiuXdKL=07NCo2vA@mail.gmail.com>
Subject: Re: linux-next: build failure after merge of the final tree
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Frysinger <vapier.adi@gmail.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Dipankar Sarma <dipankar@in.ibm.com>

On Mon, May 23, 2011 at 7:06 PM, Mike Frysinger <vapier.adi@gmail.com> wrote:
>
> more failures:

Is this blackfin or something?

I did an allyesconfig with a special x86 patch that should have caught
everything that didn't have the proper prefetch.h include, but non-x86
drivers would have passed that.

And I guess I didn't do my "force staging drivers on" hack for that test either.

                      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
