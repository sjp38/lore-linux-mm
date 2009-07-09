Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6630A6B004D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 17:29:38 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <fa083462-f28d-4188-9006-a285141acc21@default>
Date: Thu, 9 Jul 2009 14:48:10 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC PATCH 0/4] (Take 2): transcendent memory ("tmem") for Linux
In-Reply-To: <4A5660CB.5080607@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Anthony Liguori <anthony@codemonkey.ws>, linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, dave.mccracken@oracle.com, Marcelo Tosatti <mtosatti@redhat.com>, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, chris.mason@oracle.com, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> > I'm not saying either one is bad or good -- and I'm sure
> > each can be adapted to approximately deliver the value
> > of the other -- they are just approaching the same problem
> > from different perspectives.
>=20
> Indeed.  Tmem and auto-ballooning have a simple mechanism,
> but the policy required to make it work right could well
> be too complex to ever get right.
>=20
> CMM2 has a more complex mechanism, but the policy is
> absolutely trivial.

Could you elaborate a bit more on what policy you
are referring to and what decisions the policies are
trying to guide?  And are you looking at the policies
in Linux or in the hypervisor or the sum of both?

The Linux-side policies in the tmem patch seem trivial
to me and the Xen-side implementation is certainly
working correctly, though "working right" is a hard
objective to measure.  But depending on how you define
"working right", the pageframe replacement algorithm
in Linux may also be "too complex to ever get right"
but it's been working well enough for a long time.

> CMM2 and auto-ballooning seem to give about similar
> performance gains on zSystem.

Tmem provides a huge advantage over my self-ballooning
implementation, but maybe that's because it is more
aggressive than the CMM auto-ballooning, resulting
in more refaults that must be "fixed".

> I suspect that for Xen and KVM, we'll want to choose
> for the approach that has the simpler policy, because
> relying on different versions of different operating
> systems to all get the policy of auto-ballooning or
> tmem right is likely to result in bad interactions
> between guests and other intractable issues.

Again, not sure what tmem policy in Linux you are referring
to or what bad interactions you foresee.  Could you
clarify?

Auto-ballooning policy is certainly a challenge, but
that's true whether CMM or tmem, right?

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
