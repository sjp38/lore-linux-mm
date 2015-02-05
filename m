Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id B940F828FD
	for <linux-mm@kvack.org>; Thu,  5 Feb 2015 15:45:30 -0500 (EST)
Received: by pdbnh10 with SMTP id nh10so7347657pdb.0
        for <linux-mm@kvack.org>; Thu, 05 Feb 2015 12:45:30 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id qi4si7632973pac.85.2015.02.05.12.45.29
        for <linux-mm@kvack.org>;
        Thu, 05 Feb 2015 12:45:29 -0800 (PST)
From: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>
Subject: RE: [next:master 4658/4676] undefined reference to `copy_user_page'
Date: Thu, 5 Feb 2015 20:45:26 +0000
Message-ID: <100D68C7BA14664A8938383216E40DE0408569A1@FMSMSX114.amr.corp.intel.com>
References: <201501221315.sbz4rdsB%fengguang.wu@intel.com>
	<100D68C7BA14664A8938383216E40DE040853FB4@FMSMSX114.amr.corp.intel.com>
	<20150205122115.8fe1037870b76d75afc3fb03@linux-foundation.org>
	<100D68C7BA14664A8938383216E40DE040856952@FMSMSX114.amr.corp.intel.com>
 <20150205122552.1485c1439ec6c019e9443c51@linux-foundation.org>
In-Reply-To: <20150205122552.1485c1439ec6c019e9443c51@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Wu, Fengguang" <fengguang.wu@intel.com>, "kbuild-all@01.org" <kbuild-all@01.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>, "linux-arm-kernel@lists.arm.linux.org.uk" <linux-arm-kernel@lists.arm.linux.org.uk>

MIPS: https://lkml.org/lkml/2015/1/31/1
ARM: https://marc.info/?l=3Dlinaro-kernel&m=3D142253251904005&w=3D3

-----Original Message-----
From: Andrew Morton [mailto:akpm@linux-foundation.org]=20
Sent: Thursday, February 05, 2015 12:26 PM
To: Wilcox, Matthew R
Cc: Wu, Fengguang; kbuild-all@01.org; Linux Memory Management List; linux-m=
ips@linux-mips.org; linux-arm-kernel@lists.arm.linux.org.uk
Subject: Re: [next:master 4658/4676] undefined reference to `copy_user_page=
'

On Thu, 5 Feb 2015 20:22:34 +0000 "Wilcox, Matthew R" <matthew.r.wilcox@int=
el.com> wrote:

>=20
> -----Original Message-----
> From: Andrew Morton [mailto:akpm@linux-foundation.org]=20
> Sent: Thursday, February 05, 2015 12:21 PM
> To: Wilcox, Matthew R
> Cc: Wu, Fengguang; kbuild-all@01.org; Linux Memory Management List; linux=
-mips@linux-mips.org; linux-arm-kernel@lists.arm.linux.org.uk
> Subject: Re: [next:master 4658/4676] undefined reference to `copy_user_pa=
ge'
>=20
> On Thu, 22 Jan 2015 15:12:15 +0000 "Wilcox, Matthew R" <matthew.r.wilcox@=
intel.com> wrote:
>=20
> > Looks like mips *declares* copy_user_page(), but never *defines* an imp=
lementation.
> >=20
> > It's documented in Documentation/cachetlb.txt, but it's not (currently)=
 called if the architecture defines its own copy_user_highpage(), so some b=
itrot has occurred.  ARM is currently fixing this, and MIPS will need to do=
 the same.
> >=20
> > (We can't use copy_user_highpage() in DAX because we don't necessarily =
have a struct page for 'from'.)
>=20
> > Has there been any progress on this?  It would be unpleasant to merge
> > DAX into 3.19 and break MIPS and ARM.
>
> Yes, both MIPS and ARM have sent patches out for this.

I'm not seeing either in linux-next.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
