Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id EC2746B004D
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 00:19:34 -0500 (EST)
Received: from mail180-tx2 (localhost [127.0.0.1])	by
 mail180-tx2-R.bigfish.com (Postfix) with ESMTP id 3A3321601B9	for
 <linux-mm@kvack.org.FOPE.CONNECTOR.OVERRIDE>; Tue, 13 Nov 2012 05:16:38 +0000
 (UTC)
From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 1/1] mm: Export a function to read vm_committed_as
Date: Tue, 13 Nov 2012 05:16:33 +0000
Message-ID: <426367E2313C2449837CD2DE46E7EAF930E3E07D@BL2PRD0310MB375.namprd03.prod.outlook.com>
References: <1352600728-17766-1-git-send-email-kys@microsoft.com>
 <alpine.DEB.2.00.1211101830250.18494@chino.kir.corp.google.com>
 <426367E2313C2449837CD2DE46E7EAF930E35B45@SN2PRD0310MB382.namprd03.prod.outlook.com>
 <alpine.DEB.2.00.1211121349130.23347@chino.kir.corp.google.com>
 <426367E2313C2449837CD2DE46E7EAF930E39FBC@SN2PRD0310MB382.namprd03.prod.outlook.com>
 <c04bb062-bbce-4980-b2b3-fbbb18e64b66@default>
In-Reply-To: <c04bb062-bbce-4980-b2b3-fbbb18e64b66@default>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>, David Rientjes <rientjes@google.com>, Konrad Wilk <konrad.wilk@oracle.com>
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyuki@gmail.com" <kamezawa.hiroyuki@gmail.com>, "mhocko@suse.cz" <mhocko@suse.cz>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "yinghan@google.com" <yinghan@google.com>



> -----Original Message-----
> From: Dan Magenheimer [mailto:dan.magenheimer@oracle.com]
> Sent: Monday, November 12, 2012 6:32 PM
> To: KY Srinivasan; David Rientjes; Konrad Wilk
> Cc: gregkh@linuxfoundation.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> andi@firstfloor.org; akpm@linux-foundation.org; linux-mm@kvack.org;
> kamezawa.hiroyuki@gmail.com; mhocko@suse.cz; hannes@cmpxchg.org;
> yinghan@google.com
> Subject: RE: [PATCH 1/1] mm: Export a function to read vm_committed_as
>=20
> > From: KY Srinivasan [mailto:kys@microsoft.com]
> > Sent: Monday, November 12, 2012 3:58 PM
> > To: David Rientjes
> > Cc: gregkh@linuxfoundation.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org;
> > olaf@aepfle.de; apw@canonical.com; andi@firstfloor.org; akpm@linux-
> foundation.org; linux-mm@kvack.org;
> > kamezawa.hiroyuki@gmail.com; mhocko@suse.cz; hannes@cmpxchg.org;
> yinghan@google.com; Dan Magenheimer
> > Subject: RE: [PATCH 1/1] mm: Export a function to read vm_committed_as
> >
> > > -----Original Message-----
> > > From: David Rientjes [mailto:rientjes@google.com]
> > > Sent: Monday, November 12, 2012 4:54 PM
> > > To: KY Srinivasan
> > > Cc: gregkh@linuxfoundation.org; linux-kernel@vger.kernel.org;
> > > devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> > > andi@firstfloor.org; akpm@linux-foundation.org; linux-mm@kvack.org;
> > > kamezawa.hiroyuki@gmail.com; mhocko@suse.cz; hannes@cmpxchg.org;
> > > yinghan@google.com
> > > Subject: RE: [PATCH 1/1] mm: Export a function to read vm_committed_a=
s
> > >
> > > On Sun, 11 Nov 2012, KY Srinivasan wrote:
> > >
> > > > Thanks for the prompt response. For the Linux balloon driver for Hy=
per-V, I
> > > need access
> > > > to the metric that reflects the system wide memory commitment made =
by
> the
> > > guest kernel.
> > > > In the Hyper-V case, this information is one of the many metrics us=
ed to
> drive
> > > the policy engine
> > > > on the host. Granted, the interface name I have chosen here could b=
e more
> > > generic; how about
> > > > read_mem_commit_info(void). I am open to suggestions here.
> > > >
> > >
> > > I would suggest vm_memory_committed() and there shouldn't be a
> comment
> > > describing that this is just a wrapper for modules to read
> > > vm_committed_as, that's apparent from the implementation: it should b=
e
> > > describing exactly what this value represents and why it is a useful
> > > metric (at least in the case that you're concerned about).
> >
> > Will do; thanks.
> > >
> > > > With regards to making changes to the Xen self ballooning code, I w=
ould like
> to
> > > separate that patch
> > > > from the patch that implements the exported mechanism to access the
> > > memory commitment information.
> > >
> > > Why?  Is xen using it for a different inference?
> >
> > I think it is good to separate these patches. Dan (copied here) wrote t=
he code
> for the
> > Xen self balloon driver. If it is ok with him I can submit the patch fo=
r Xen as well.
>=20
> Hi KY --
>=20
> If I understand correctly, this would be only a cosmetic (function renami=
ng)
> change
> to the Xen selfballooning code.  If so, then I will be happy to Ack when =
I
> see the patch.  However, Konrad (konrad.wilk@oracle.com) is the maintaine=
r
> for all Xen code so you should ask him... and (from previous painful expe=
rience)
> it can be difficult to sync even very simple interdependent changes going=
 through
> different maintainers without breaking linux-next.  So I can't offer any
> help with that process, only commiseration. :-(
>=20
> Dan
>=20

Dan,

Thank you. I will send the patches out soon.

Regards,

K. Y

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
