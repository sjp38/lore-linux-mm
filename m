Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 933C76B006C
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 18:32:32 -0500 (EST)
MIME-Version: 1.0
Message-ID: <c04bb062-bbce-4980-b2b3-fbbb18e64b66@default>
Date: Mon, 12 Nov 2012 15:32:11 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 1/1] mm: Export a function to read vm_committed_as
References: <1352600728-17766-1-git-send-email-kys@microsoft.com>
 <alpine.DEB.2.00.1211101830250.18494@chino.kir.corp.google.com>
 <426367E2313C2449837CD2DE46E7EAF930E35B45@SN2PRD0310MB382.namprd03.prod.outlook.com>
 <alpine.DEB.2.00.1211121349130.23347@chino.kir.corp.google.com>
 <426367E2313C2449837CD2DE46E7EAF930E39FBC@SN2PRD0310MB382.namprd03.prod.outlook.com>
In-Reply-To: <426367E2313C2449837CD2DE46E7EAF930E39FBC@SN2PRD0310MB382.namprd03.prod.outlook.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KY Srinivasan <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Konrad Wilk <konrad.wilk@oracle.com>
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com, andi@firstfloor.org, akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyuki@gmail.com, mhocko@suse.cz, hannes@cmpxchg.org, yinghan@google.com

> From: KY Srinivasan [mailto:kys@microsoft.com]
> Sent: Monday, November 12, 2012 3:58 PM
> To: David Rientjes
> Cc: gregkh@linuxfoundation.org; linux-kernel@vger.kernel.org; devel@linux=
driverproject.org;
> olaf@aepfle.de; apw@canonical.com; andi@firstfloor.org; akpm@linux-founda=
tion.org; linux-mm@kvack.org;
> kamezawa.hiroyuki@gmail.com; mhocko@suse.cz; hannes@cmpxchg.org; yinghan@=
google.com; Dan Magenheimer
> Subject: RE: [PATCH 1/1] mm: Export a function to read vm_committed_as
>=20
> > -----Original Message-----
> > From: David Rientjes [mailto:rientjes@google.com]
> > Sent: Monday, November 12, 2012 4:54 PM
> > To: KY Srinivasan
> > Cc: gregkh@linuxfoundation.org; linux-kernel@vger.kernel.org;
> > devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> > andi@firstfloor.org; akpm@linux-foundation.org; linux-mm@kvack.org;
> > kamezawa.hiroyuki@gmail.com; mhocko@suse.cz; hannes@cmpxchg.org;
> > yinghan@google.com
> > Subject: RE: [PATCH 1/1] mm: Export a function to read vm_committed_as
> >
> > On Sun, 11 Nov 2012, KY Srinivasan wrote:
> >
> > > Thanks for the prompt response. For the Linux balloon driver for Hype=
r-V, I
> > need access
> > > to the metric that reflects the system wide memory commitment made by=
 the
> > guest kernel.
> > > In the Hyper-V case, this information is one of the many metrics used=
 to drive
> > the policy engine
> > > on the host. Granted, the interface name I have chosen here could be =
more
> > generic; how about
> > > read_mem_commit_info(void). I am open to suggestions here.
> > >
> >
> > I would suggest vm_memory_committed() and there shouldn't be a comment
> > describing that this is just a wrapper for modules to read
> > vm_committed_as, that's apparent from the implementation: it should be
> > describing exactly what this value represents and why it is a useful
> > metric (at least in the case that you're concerned about).
>=20
> Will do; thanks.
> >
> > > With regards to making changes to the Xen self ballooning code, I wou=
ld like to
> > separate that patch
> > > from the patch that implements the exported mechanism to access the
> > memory commitment information.
> >
> > Why?  Is xen using it for a different inference?
>=20
> I think it is good to separate these patches. Dan (copied here) wrote the=
 code for the
> Xen self balloon driver. If it is ok with him I can submit the patch for =
Xen as well.

Hi KY --

If I understand correctly, this would be only a cosmetic (function renaming=
) change
to the Xen selfballooning code.  If so, then I will be happy to Ack when I
see the patch.  However, Konrad (konrad.wilk@oracle.com) is the maintainer
for all Xen code so you should ask him... and (from previous painful experi=
ence)
it can be difficult to sync even very simple interdependent changes going t=
hrough
different maintainers without breaking linux-next.  So I can't offer any
help with that process, only commiseration. :-(

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
