Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 83E326B0069
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 14:57:20 -0400 (EDT)
Message-ID: <1340996224.28750.116.camel@twins>
Subject: Re: [PATCH 13/40] autonuma: CPU follow memory algorithm
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Fri, 29 Jun 2012 20:57:04 +0200
In-Reply-To: <4FEDF81C.1010401@redhat.com>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
	  <1340888180-15355-14-git-send-email-aarcange@redhat.com>
	  <1340895238.28750.49.camel@twins>
	  <CAJd=RBA+FPgB9iq07YG0Pd=tN65SGK1ifmj98tomBDbYeKOE-Q@mail.gmail.com>
	  <20120629125517.GD32637@gmail.com> <4FEDDD0C.60609@redhat.com>
	 <1340995260.28750.103.camel@twins> <4FEDF81C.1010401@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: dlaor@redhat.com, Ingo Molnar <mingo@kernel.org>, Hillf Danton <dhillf@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Fri, 2012-06-29 at 14:46 -0400, Rik van Riel wrote:
>=20
> I am not convinced all architectures that have CONFIG_NUMA
> need to be a requirement, since some of them (eg. Alpha)
> seem to be lacking a maintainer nowadays.=20

Still, this NUMA balancing stuff is not a small tweak to load-balancing.
Its a very significant change is how you schedule. Having such great
differences over architectures isn't something I look forward to.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
