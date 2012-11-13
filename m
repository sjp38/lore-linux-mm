Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 75E986B005D
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 00:26:08 -0500 (EST)
Received: from mail81-am1 (localhost [127.0.0.1])	by mail81-am1-R.bigfish.com
 (Postfix) with ESMTP id 86CC83201C9	for
 <linux-mm@kvack.org.FOPE.CONNECTOR.OVERRIDE>; Tue, 13 Nov 2012 05:25:04 +0000
 (UTC)
From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 1/1] mm: Export a function to read vm_committed_as
Date: Tue, 13 Nov 2012 05:24:57 +0000
Message-ID: <426367E2313C2449837CD2DE46E7EAF930E3E0B5@BL2PRD0310MB375.namprd03.prod.outlook.com>
References: <1352600728-17766-1-git-send-email-kys@microsoft.com>
 <alpine.DEB.2.00.1211101830250.18494@chino.kir.corp.google.com>
 <426367E2313C2449837CD2DE46E7EAF930E35B45@SN2PRD0310MB382.namprd03.prod.outlook.com>
 <alpine.DEB.2.00.1211121349130.23347@chino.kir.corp.google.com>
 <426367E2313C2449837CD2DE46E7EAF930E39FBC@SN2PRD0310MB382.namprd03.prod.outlook.com>
 <c04bb062-bbce-4980-b2b3-fbbb18e64b66@default>
 <alpine.DEB.2.00.1211121547450.3841@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1211121547450.3841@chino.kir.corp.google.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Konrad Wilk <konrad.wilk@oracle.com>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyuki@gmail.com" <kamezawa.hiroyuki@gmail.com>, "mhocko@suse.cz" <mhocko@suse.cz>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "yinghan@google.com" <yinghan@google.com>



> -----Original Message-----
> From: David Rientjes [mailto:rientjes@google.com]
> Sent: Monday, November 12, 2012 6:49 PM
> To: Dan Magenheimer
> Cc: KY Srinivasan; Konrad Wilk; gregkh@linuxfoundation.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; andi@firstfloor.org; akpm@linux-foundation.org; linux-
> mm@kvack.org; kamezawa.hiroyuki@gmail.com; mhocko@suse.cz;
> hannes@cmpxchg.org; yinghan@google.com
> Subject: RE: [PATCH 1/1] mm: Export a function to read vm_committed_as
>=20
> On Mon, 12 Nov 2012, Dan Magenheimer wrote:
>=20
> > > > Why?  Is xen using it for a different inference?
> > >
> > > I think it is good to separate these patches. Dan (copied here) wrote=
 the code
> for the
> > > Xen self balloon driver. If it is ok with him I can submit the patch =
for Xen as
> well.
> >
> > Hi KY --
> >
> > If I understand correctly, this would be only a cosmetic (function rena=
ming)
> change
> > to the Xen selfballooning code.  If so, then I will be happy to Ack whe=
n I
> > see the patch.  However, Konrad (konrad.wilk@oracle.com) is the maintai=
ner
> > for all Xen code so you should ask him... and (from previous painful ex=
perience)
> > it can be difficult to sync even very simple interdependent changes goi=
ng
> through
> > different maintainers without breaking linux-next.  So I can't offer an=
y
> > help with that process, only commiseration. :-(
> >
>=20
> I think this should be done in the same patch as the function getting
> introduced with a cc to Konrad and routed through -mm; even better,
> perhaps he'll have some useful comments for how this is used for xen that
> can be included for context.
>=20
Ok; I will send out a single patch. I am hoping this can be applied soon as=
 Hyper-V balloon
driver is queued behind this.

Regards,

K. Y



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
