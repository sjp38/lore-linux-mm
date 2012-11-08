Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 57A0E6B0044
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 17:09:53 -0500 (EST)
Received: from mail96-co9 (localhost [127.0.0.1])	by mail96-co9-R.bigfish.com
 (Postfix) with ESMTP id 87DF8D0054E	for
 <linux-mm@kvack.org.FOPE.CONNECTOR.OVERRIDE>; Thu,  8 Nov 2012 22:08:39 +0000
 (UTC)
From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 1/2] mm: Export vm_committed_as
Date: Thu, 8 Nov 2012 22:08:33 +0000
Message-ID: <426367E2313C2449837CD2DE46E7EAF930E0E0EB@CH1PRD0310MB381.namprd03.prod.outlook.com>
References: <1349654347-18337-1-git-send-email-kys@microsoft.com>
	<1349654386-18378-1-git-send-email-kys@microsoft.com>
	<20121008004358.GA12342@kroah.com>
	<426367E2313C2449837CD2DE46E7EAF930A1FB31@SN2PRD0310MB382.namprd03.prod.outlook.com>
	<20121008133539.GA15490@kroah.com>
	<20121009124755.ce1087b4.akpm@linux-foundation.org>
	<426367E2313C2449837CD2DE46E7EAF930DF7FBB@SN2PRD0310MB382.namprd03.prod.outlook.com>
	<20121105134456.f655b85a.akpm@linux-foundation.org>
	<426367E2313C2449837CD2DE46E7EAF930DFA7B8@SN2PRD0310MB382.namprd03.prod.outlook.com>
	<alpine.DEB.2.00.1211051418560.5296@chino.kir.corp.google.com>
	<426367E2313C2449837CD2DE46E7EAF930E0D0CC@CH1PRD0310MB381.namprd03.prod.outlook.com>
 <20121108140529.af7849c8.akpm@linux-foundation.org>
In-Reply-To: <20121108140529.af7849c8.akpm@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Greg KH <gregkh@linuxfoundation.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "andi@firstfloor.org" <andi@firstfloor.org>, "apw@canonical.com" <apw@canonical.com>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>



> -----Original Message-----
> From: Andrew Morton [mailto:akpm@linux-foundation.org]
> Sent: Thursday, November 08, 2012 5:05 PM
> To: KY Srinivasan
> Cc: David Rientjes; Greg KH; olaf@aepfle.de; linux-kernel@vger.kernel.org=
;
> andi@firstfloor.org; apw@canonical.com; devel@linuxdriverproject.org; lin=
ux-
> mm@kvack.org; Hiroyuki Kamezawa; Michal Hocko; Johannes Weiner; Ying Han
> Subject: Re: [PATCH 1/2] mm: Export vm_committed_as
>=20
> On Thu, 8 Nov 2012 22:01:33 +0000
> KY Srinivasan <kys@microsoft.com> wrote:
>=20
> >
> >
> > > -----Original Message-----
> > > From: David Rientjes [mailto:rientjes@google.com]
> > > Sent: Monday, November 05, 2012 5:33 PM
> > > To: KY Srinivasan
> > > Cc: Andrew Morton; Greg KH; olaf@aepfle.de; linux-kernel@vger.kernel.=
org;
> > > andi@firstfloor.org; apw@canonical.com; devel@linuxdriverproject.org;
> linux-
> > > mm@kvack.org; Hiroyuki Kamezawa; Michal Hocko; Johannes Weiner; Ying
> Han
> > > Subject: RE: [PATCH 1/2] mm: Export vm_committed_as
> > >
> > > On Mon, 5 Nov 2012, KY Srinivasan wrote:
> > >
> > > > The Hyper-V host has a policy engine for managing available physica=
l
> memory
> > > across
> > > > competing virtual machines. This policy decision is based on a numb=
er of
> > > parameters
> > > > including the memory pressure reported by the guest. Currently, the
> pressure
> > > calculation is
> > > > based on the memory commitment made by the guest. From what I can
> tell,
> > > the ratio of
> > > > currently allocated physical memory to the current memory commitmen=
t
> made
> > > by the guest
> > > > (vm_committed_as) is used as one of the parameters in making the
> memory
> > > balancing decision on
> > > > the host. This is what Windows guests report to the host. So, I nee=
d some
> > > measure of memory
> > > > commitments made by the Linux guest. This is the reason I want expo=
rt
> > > vm_committed_as.
> > > >
> > >
> > > I don't think you should export the symbol itself to modules but rath=
er a
> > > helper function that returns s64 that just wraps
> > > percpu_counter_read_positive() which your driver could use instead.
> > >
> > > (And why percpu_counter_read_positive() returns a signed type is a
> > > mystery.)
> >
> > Yes, this makes sense. I just want to access (read) this metric. Andrew=
, if you
> are willing to
> > take this patch, I could send one.
>=20
> Sure.  I suppose that's better, although any module which modifies
> committed_as would never pass review (rofl).

Thanks Andrew; I will send the patch out along with the appropriately modif=
ied balloon driver patch.

Regards,

K. Y
>=20
>=20


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
