Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7E5FE6B0248
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 07:02:13 -0400 (EDT)
Subject: Re: FYI: mmap_sem OOM patch
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100708195421.CD48.A69D9226@jp.fujitsu.com>
References: <AANLkTimLSnNot2byTWYuIHE8rhGLXbl1zKsQQhmci1Do@mail.gmail.com>
	 <1278586173.1900.50.camel@laptop>
	 <20100708195421.CD48.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 08 Jul 2010 13:02:01 +0200
Message-ID: <1278586921.1900.67.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Michel Lespinasse <walken@google.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Divyesh Shah <dpshah@google.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-07-08 at 19:57 +0900, KOSAKI Motohiro wrote:
> > On Thu, 2010-07-08 at 03:39 -0700, Michel Lespinasse wrote:
> > >=20
> > >=20
> > >         One way to fix this is to have T4 wake from the oom queue and=
 return an
> > >         allocation failure instead of insisting on going oom itself w=
hen T1
> > >         decides to take down the task.
> > >=20
> > > How would you have T4 figure out the deadlock situation ? T1 is takin=
g down T2, not T4...=20
> >=20
> > If T2 and T4 share a mmap_sem they belong to the same process. OOM take=
s
> > down the whole process by sending around signals of sorts (SIGKILL?), s=
o
> > if T4 gets a fatal signal while it is waiting to enter the oom thingy,
> > have it abort and return an allocation failure.
> >=20
> > That alloc failure (along with a pending fatal signal) will very likely
> > lead to the release of its mmap_sem (if not, there's more things to
> > cure).
> >=20
> > At which point the cycle is broken an stuff continues as it was
> > intended.
>=20
> Now, I've reread current code. I think mmotm already have this.

<snip code>

[ small note on that we really should kill __GFP_NOFAIL, its utter
deadlock potential ]

> Thought?

So either its not working or google never tried that code?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
