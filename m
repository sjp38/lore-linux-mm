Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id DA0E46B0044
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 17:16:36 -0500 (EST)
Received: from mail152-ch1 (localhost [127.0.0.1])	by
 mail152-ch1-R.bigfish.com (Postfix) with ESMTP id 3FB4F60193	for
 <linux-mm@kvack.org.FOPE.CONNECTOR.OVERRIDE>; Mon,  5 Nov 2012 22:12:29 +0000
 (UTC)
From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 1/2] mm: Export vm_committed_as
Date: Mon, 5 Nov 2012 22:12:25 +0000
Message-ID: <426367E2313C2449837CD2DE46E7EAF930DFA7B8@SN2PRD0310MB382.namprd03.prod.outlook.com>
References: <1349654347-18337-1-git-send-email-kys@microsoft.com>
	<1349654386-18378-1-git-send-email-kys@microsoft.com>
	<20121008004358.GA12342@kroah.com>
	<426367E2313C2449837CD2DE46E7EAF930A1FB31@SN2PRD0310MB382.namprd03.prod.outlook.com>
	<20121008133539.GA15490@kroah.com>
	<20121009124755.ce1087b4.akpm@linux-foundation.org>
	<426367E2313C2449837CD2DE46E7EAF930DF7FBB@SN2PRD0310MB382.namprd03.prod.outlook.com>
 <20121105134456.f655b85a.akpm@linux-foundation.org>
In-Reply-To: <20121105134456.f655b85a.akpm@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg KH <gregkh@linuxfoundation.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "andi@firstfloor.org" <andi@firstfloor.org>, "apw@canonical.com" <apw@canonical.com>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>



> -----Original Message-----
> From: Andrew Morton [mailto:akpm@linux-foundation.org]
> Sent: Monday, November 05, 2012 4:45 PM
> To: KY Srinivasan
> Cc: Greg KH; olaf@aepfle.de; linux-kernel@vger.kernel.org; andi@firstfloo=
r.org;
> apw@canonical.com; devel@linuxdriverproject.org; linux-mm@kvack.org;
> Hiroyuki Kamezawa; Michal Hocko; Johannes Weiner; Ying Han
> Subject: Re: [PATCH 1/2] mm: Export vm_committed_as
>=20
> On Sat, 3 Nov 2012 14:09:38 +0000
> KY Srinivasan <kys@microsoft.com> wrote:
>=20
> >
> >
> > > >
> > > > Ok, but you're going to have to get the -mm developers to agree tha=
t
> > > > this is ok before I can accept it.
> > >
> > > Well I guess it won't kill us.
> >
> > Andrew,
> >
> > I presumed this was an Ack from you with regards to exporting the
> > symbol. Looks like Greg is waiting to hear from you before he can check
> > these patches in. Could you provide an explicit Ack.
> >
>=20
> Well, I do have some qualms about exporting vm_committed_as to modules.
>=20
> vm_committed_as is a global thing and only really makes sense in a
> non-containerised system.  If the application is running within a
> memory cgroup then vm_enough_memory() and the global overcommit policy
> are at best irrelevant and misleading.
>=20
> If use of vm_committed_as is indeed a bad thing, then exporting it to
> modules might increase the amount of badness in the kernel.
>=20
>=20
> I don't think these qualms are serious enough to stand in the way of
> this patch, but I'd be interested in hearing the memcg developers'
> thoughts on the matter?
>=20
>=20
> Perhaps you could provide a detailed description of why your module
> actually needs this?  Precisely what information is it looking for
> and why?  If we know that then perhaps a more comfortable alternative
> can be found.

The Hyper-V host has a policy engine for managing available physical memory=
 across
competing virtual machines. This policy decision is based on a number of pa=
rameters
including the memory pressure reported by the guest. Currently, the pressur=
e calculation is
based on the memory commitment made by the guest. From what I can tell, the=
 ratio of
currently allocated physical memory to the current memory commitment made b=
y the guest
(vm_committed_as) is used as one of the parameters in making the memory bal=
ancing decision on
the host. This is what Windows guests report to the host. So, I need some m=
easure of memory
commitments made by the Linux guest. This is the reason I want export vm_co=
mmitted_as.=20

Regards,

K. Y =20



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
