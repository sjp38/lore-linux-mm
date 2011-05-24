Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C88EF6B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 13:30:52 -0400 (EDT)
Received: from mail-ey0-f169.google.com (mail-ey0-f169.google.com [209.85.215.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p4OHUJB3014244
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:30:20 -0700
Received: by eyd9 with SMTP id 9so3343141eyd.14
        for <linux-mm@kvack.org>; Tue, 24 May 2011 10:30:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTi=U8ikZo65AoxGznCopGMTFOUXWhQ@mail.gmail.com>
References: <20110520161816.dda6f1fd.sfr@canb.auug.org.au> <BANLkTimjzzqTS1fELmpb0UivqseLsYOfPw@mail.gmail.com>
 <BANLkTine2kobQA8TkmtiuXdKL=07NCo2vA@mail.gmail.com> <BANLkTim-zRShhy49d7yn5WTJYzR6A2DtZQ@mail.gmail.com>
 <BANLkTi=U8ikZo65AoxGznCopGMTFOUXWhQ@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 24 May 2011 10:29:58 -0700
Message-ID: <BANLkTi=7wfhw-J09U7X-crKcDUPwpzbsNA@mail.gmail.com>
Subject: Re: linux-next: build failure after merge of the final tree
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Frysinger <vapier.adi@gmail.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Dipankar Sarma <dipankar@in.ibm.com>, "Balbi, Felipe" <balbi@ti.com>

On Tue, May 24, 2011 at 10:10 AM, Mike Frysinger <vapier.adi@gmail.com> wro=
te:
>
> latest tree seems to only fail for me now on the musb driver. =A0i can
> send out a patch later today if no one else has gotten to it yet.

Please do.

I did a

  grep -L linux/prefetch.h $(git grep -l '[^a-z_]prefetchw*(' -- '*.[ch]')

but there are drivers out there that have that "prefetch()" pattern
without being about actual CPU prefetching at all (see for example
drivers/ide/cmd640.c), so once I got allyesconfig with my x86
detection hack going, I didn't bother with the few odd men out.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
