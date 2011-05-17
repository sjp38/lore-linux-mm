Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C74696B0012
	for <linux-mm@kvack.org>; Tue, 17 May 2011 17:54:40 -0400 (EDT)
Subject: Re: [PATCH 1/3] comm: Introduce comm_lock spinlock to protect
 task->comm access
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110517212734.GB28054@elte.hu>
References: <1305665263-20933-1-git-send-email-john.stultz@linaro.org>
	 <1305665263-20933-2-git-send-email-john.stultz@linaro.org>
	 <20110517212734.GB28054@elte.hu>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 17 May 2011 23:54:16 +0200
Message-ID: <1305669256.2466.6286.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: John Stultz <john.stultz@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Joe Perches <joe@perches.com>, Michal Nazarewicz <mina86@mina86.com>, Andy Whitcroft <apw@canonical.com>, Jiri Slaby <jirislaby@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, 2011-05-17 at 23:27 +0200, Ingo Molnar wrote:
> * John Stultz <john.stultz@linaro.org> wrote:
>=20
> > The implicit rules for current->comm access being safe without locking =
are no=20
> > longer true. Accessing current->comm without holding the task lock may =
result=20
> > in null or incomplete strings (however, access won't run off the end of=
 the=20
> > string).
>=20
> This is rather unfortunate - task->comm is used in a number of performanc=
e=20
> critical codepaths such as tracing.
>=20
> Why does this matter so much? A NULL string is not a big deal.
>=20
> Note, since task->comm is 16 bytes there's the CMPXCHG16B instruction on =
x86=20
> which could be used to update it atomically, should atomicity really be=
=20
> desired.

The changelog also fails to mention _WHY_ this is no longer true. Nor
does it treat why making it true again isn't an option.

Who is changing another task's comm? That's just silly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
