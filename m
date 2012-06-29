Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 2C5B46B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 16:27:46 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so6572599lbj.14
        for <linux-mm@kvack.org>; Fri, 29 Jun 2012 13:27:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1340996661.28750.124.camel@twins>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
	<1340888180-15355-14-git-send-email-aarcange@redhat.com>
	<1340895238.28750.49.camel@twins>
	<CAJd=RBA+FPgB9iq07YG0Pd=tN65SGK1ifmj98tomBDbYeKOE-Q@mail.gmail.com>
	<20120629125517.GD32637@gmail.com>
	<4FEDDD0C.60609@redhat.com>
	<1340996661.28750.124.camel@twins>
Date: Sat, 30 Jun 2012 04:27:44 +0800
Message-ID: <CAPQyPG7SSb=vDC4OcgAN43A7CVS=E=xo7zOoFua6de+qYjLrgg@mail.gmail.com>
Subject: Re: [PATCH 13/40] autonuma: CPU follow memory algorithm
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: dlaor@redhat.com, Ingo Molnar <mingo@kernel.org>, Hillf Danton <dhillf@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Sat, Jun 30, 2012 at 3:04 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wr=
ote:
> On Fri, 2012-06-29 at 12:51 -0400, Dor Laor wrote:
>> Some developers have a thick skin and nothing gets in, others are human
>> and have feelings. Using a tiny difference in behavior we can do much
>> much better. What's works in a f2f loud discussion doesn't play well in
>> email.
>
> We're all humans, we all have feelings, and I'm frigging upset.
>
> As a maintainer I try and do my best to support and maintain the
> subsystems I'm responsible for. I take this very serious.

So, would you please very seriously look into my NAK ?
It's looks very clear to me.

>
> I don't agree with the approach Andrea takes, we all know that, yet I do
> want to talk about it. The problem is, many of the crucial details are
> non-obvious and no sane explanation seems forthcoming.
>
> I really feel I'm talking to deaf ears.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a hrefmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
