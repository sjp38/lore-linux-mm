Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C27766B0047
	for <linux-mm@kvack.org>; Sun, 17 Jan 2010 10:09:35 -0500 (EST)
Subject: Re: [PATCH v3 04/12] Add "handle page fault" PV helper.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100117144411.GI31692@redhat.com>
References: <1262700774-1808-1-git-send-email-gleb@redhat.com>
	 <1262700774-1808-5-git-send-email-gleb@redhat.com>
	 <1263490267.4244.340.camel@laptop>  <20100117144411.GI31692@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Sun, 17 Jan 2010 16:09:40 +0100
Message-ID: <1263740980.557.20980.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Sun, 2010-01-17 at 16:44 +0200, Gleb Natapov wrote:
> On Thu, Jan 14, 2010 at 06:31:07PM +0100, Peter Zijlstra wrote:
> > On Tue, 2010-01-05 at 16:12 +0200, Gleb Natapov wrote:
> > > Allow paravirtualized guest to do special handling for some page faul=
ts.
> > >=20
> > > The patch adds one 'if' to do_page_fault() function. The call is patc=
hed
> > > out when running on physical HW. I ran kernbech on the kernel with an=
d
> > > without that additional 'if' and result were rawly the same:
> >=20
> > So why not program a different handler address for the #PF/#GP faults
> > and avoid the if all together?
> I would gladly use fault vector reserved by x86 architecture, but I am
> not sure Intel will be happy about it.

Whatever are we doing to end up in do_page_fault() as it stands? Surely
we can tell the CPU to go elsewhere to handle faults?

Isn't that as simple as calling set_intr_gate(14, my_page_fault)
somewhere on the cpuinit instead of the regular page_fault handler?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
