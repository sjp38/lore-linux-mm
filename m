Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 9D7AF6B004D
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 17:59:56 -0500 (EST)
Received: from mail93-co9 (localhost [127.0.0.1])	by mail93-co9-R.bigfish.com
 (Postfix) with ESMTP id AC282660170	for
 <linux-mm@kvack.org.FOPE.CONNECTOR.OVERRIDE>; Mon, 12 Nov 2012 22:58:18 +0000
 (UTC)
From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 1/1] mm: Export a function to read vm_committed_as
Date: Mon, 12 Nov 2012 22:58:11 +0000
Message-ID: <426367E2313C2449837CD2DE46E7EAF930E39FBC@SN2PRD0310MB382.namprd03.prod.outlook.com>
References: <1352600728-17766-1-git-send-email-kys@microsoft.com>
 <alpine.DEB.2.00.1211101830250.18494@chino.kir.corp.google.com>
 <426367E2313C2449837CD2DE46E7EAF930E35B45@SN2PRD0310MB382.namprd03.prod.outlook.com>
 <alpine.DEB.2.00.1211121349130.23347@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1211121349130.23347@chino.kir.corp.google.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyuki@gmail.com" <kamezawa.hiroyuki@gmail.com>, "mhocko@suse.cz" <mhocko@suse.cz>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "yinghan@google.com" <yinghan@google.com>, "dan.magenheimer@oracle.com" <dan.magenheimer@oracle.com>



> -----Original Message-----
> From: David Rientjes [mailto:rientjes@google.com]
> Sent: Monday, November 12, 2012 4:54 PM
> To: KY Srinivasan
> Cc: gregkh@linuxfoundation.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> andi@firstfloor.org; akpm@linux-foundation.org; linux-mm@kvack.org;
> kamezawa.hiroyuki@gmail.com; mhocko@suse.cz; hannes@cmpxchg.org;
> yinghan@google.com
> Subject: RE: [PATCH 1/1] mm: Export a function to read vm_committed_as
>=20
> On Sun, 11 Nov 2012, KY Srinivasan wrote:
>=20
> > Thanks for the prompt response. For the Linux balloon driver for Hyper-=
V, I
> need access
> > to the metric that reflects the system wide memory commitment made by t=
he
> guest kernel.
> > In the Hyper-V case, this information is one of the many metrics used t=
o drive
> the policy engine
> > on the host. Granted, the interface name I have chosen here could be mo=
re
> generic; how about
> > read_mem_commit_info(void). I am open to suggestions here.
> >
>=20
> I would suggest vm_memory_committed() and there shouldn't be a comment
> describing that this is just a wrapper for modules to read
> vm_committed_as, that's apparent from the implementation: it should be
> describing exactly what this value represents and why it is a useful
> metric (at least in the case that you're concerned about).

Will do; thanks.
>=20
> > With regards to making changes to the Xen self ballooning code, I would=
 like to
> separate that patch
> > from the patch that implements the exported mechanism to access the
> memory commitment information.
>=20
> Why?  Is xen using it for a different inference?

I think it is good to separate these patches. Dan (copied here) wrote the c=
ode for the
Xen self balloon driver. If it is ok with him I can submit the patch for Xe=
n as well.=20


Regards,

K. Y



>=20


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
