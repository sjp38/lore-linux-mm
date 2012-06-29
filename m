Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id E384B6B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 16:44:17 -0400 (EDT)
Received: by bkcjc3 with SMTP id jc3so1402294bkc.14
        for <linux-mm@kvack.org>; Fri, 29 Jun 2012 13:44:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAPQyPG4R34bi0fXHBspSpR1+gDLj2PGYpPXNLPTTTBmrRL=m4g@mail.gmail.com>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
	<1340888180-15355-14-git-send-email-aarcange@redhat.com>
	<1340895238.28750.49.camel@twins>
	<CAJd=RBA+FPgB9iq07YG0Pd=tN65SGK1ifmj98tomBDbYeKOE-Q@mail.gmail.com>
	<20120629125517.GD32637@gmail.com>
	<4FEDDD0C.60609@redhat.com>
	<1340995986.28750.114.camel@twins>
	<CAPQyPG4R34bi0fXHBspSpR1+gDLj2PGYpPXNLPTTTBmrRL=m4g@mail.gmail.com>
Date: Sat, 30 Jun 2012 04:44:15 +0800
Message-ID: <CAPQyPG6_uqKhkhjO07KgJVDb47P2Dec9EWCpTASMMU5moJkzCA@mail.gmail.com>
Subject: Re: [PATCH 13/40] autonuma: CPU follow memory algorithm
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: dlaor@redhat.com, Ingo Molnar <mingo@kernel.org>, Hillf Danton <dhillf@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Sat, Jun 30, 2012 at 4:01 AM, Nai Xia <nai.xia@gmail.com> wrote:
> On Sat, Jun 30, 2012 at 2:53 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> =
wrote:
>> On Fri, 2012-06-29 at 12:51 -0400, Dor Laor wrote:
>>> The previous comments were not shouts but the mother of all NAKs.
>>
>> I never said any such thing. I just said why should I bother reading
>> your stuff if you're ignoring most my feedback anyway.
>>
>> If you want to read that as a NAK, not my problem.
>
> Hey guys, Can I say NAK to these patches ?
>
> Now I aware that this sampling algorithm is completely broken, if we take
> a few seconds to see what it is trying to solve:
>
> We all know that LRU is try to solve the question of "what are the
> pages recently accessed?",
> so its engouth to use pte bits to approximate.
>
> However, the numa balancing problem is fundamentally like this:
>
> In some time unit,
>
> =A0 =A0 =A0W =3D pages_accessed =A0* =A0average_page_access_frequence
>
> We are trying to move process to the node having max W, =A0right?
>
> Andrea's patch can only approximate the pages_accessed number in a
> time unit(scan interval),
> I don't think it can catch even 1% of =A0average_page_access_frequence
> on a busy workload.
> Blindly assuming that all the pages' =A0average_page_access_frequence is

Oh, sorry for my typo,  I mean "frequency".


> the same is seemly
> broken to me.
>
> Sometimes, it's good to have a good view of your problem before
> spending a lot time coding.
>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org. =A0For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a hrefmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
