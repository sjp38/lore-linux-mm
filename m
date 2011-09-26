Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B0F7D9000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 04:46:47 -0400 (EDT)
Subject: Re: [PATCH 0/5] Reduce cross CPU IPI interference
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 26 Sep 2011 10:46:14 +0200
In-Reply-To: <CAOtvUMeBRv4OO9DcYJgj07_MnbfL4jT24D2YQfQN8Srj4CEzzg@mail.gmail.com>
References: <1316940890-24138-1-git-send-email-gilad@benyossef.com>
	 <1317021659.9084.51.camel@twins>
	 <CAOtvUMeBRv4OO9DcYJgj07_MnbfL4jT24D2YQfQN8Srj4CEzzg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1317026774.9084.66.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On Mon, 2011-09-26 at 11:43 +0300, Gilad Ben-Yossef wrote:
> On Mon, Sep 26, 2011 at 10:20 AM, Peter Zijlstra <a.p.zijlstra@chello.nl>=
 wrote:
> > On Sun, 2011-09-25 at 11:54 +0300, Gilad Ben-Yossef wrote:
> >> This first version creates an on_each_cpu_mask infrastructure API
> >
> > But we already have the existing smp_call_function_many() doing that.
>=20
> I might be wrong but my understanding is that smp_call_function_many()
> does not invoke the IPI handler on the current processor. The original
> code I replaced uses on_each_cpu() which does, so I figured a wrapper
> was in order and then I discovered the same wrapper in arch specific
> code.
>=20
> > The on_each_cpu() thing is mostly a hysterical relic and could be
> > completely depricated
>=20
> Wont this require each caller to call smp_call_function_* and then
> check to see if it needs to also invoke the IPI handler locally ? I
> thought that was the reason for on_each_cpu existence... What have I
> missed?

Gah, you're right.. early.. tea.. more.=20

Looks fine then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
