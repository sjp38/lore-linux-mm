Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 27775828FD
	for <linux-mm@kvack.org>; Thu,  5 Feb 2015 15:22:38 -0500 (EST)
Received: by pdbfp1 with SMTP id fp1so9817775pdb.2
        for <linux-mm@kvack.org>; Thu, 05 Feb 2015 12:22:37 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id vx6si7500885pac.141.2015.02.05.12.22.37
        for <linux-mm@kvack.org>;
        Thu, 05 Feb 2015 12:22:37 -0800 (PST)
From: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>
Subject: RE: [next:master 4658/4676] undefined reference to `copy_user_page'
Date: Thu, 5 Feb 2015 20:22:34 +0000
Message-ID: <100D68C7BA14664A8938383216E40DE040856952@FMSMSX114.amr.corp.intel.com>
References: <201501221315.sbz4rdsB%fengguang.wu@intel.com>
	<100D68C7BA14664A8938383216E40DE040853FB4@FMSMSX114.amr.corp.intel.com>
 <20150205122115.8fe1037870b76d75afc3fb03@linux-foundation.org>
In-Reply-To: <20150205122115.8fe1037870b76d75afc3fb03@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Wu, Fengguang" <fengguang.wu@intel.com>, "kbuild-all@01.org" <kbuild-all@01.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>, "linux-arm-kernel@lists.arm.linux.org.uk" <linux-arm-kernel@lists.arm.linux.org.uk>

Yes, both MIPS and ARM have sent patches out for this.

-----Original Message-----
From: Andrew Morton [mailto:akpm@linux-foundation.org]=20
Sent: Thursday, February 05, 2015 12:21 PM
To: Wilcox, Matthew R
Cc: Wu, Fengguang; kbuild-all@01.org; Linux Memory Management List; linux-m=
ips@linux-mips.org; linux-arm-kernel@lists.arm.linux.org.uk
Subject: Re: [next:master 4658/4676] undefined reference to `copy_user_page=
'

On Thu, 22 Jan 2015 15:12:15 +0000 "Wilcox, Matthew R" <matthew.r.wilcox@in=
tel.com> wrote:

> Looks like mips *declares* copy_user_page(), but never *defines* an imple=
mentation.
>=20
> It's documented in Documentation/cachetlb.txt, but it's not (currently) c=
alled if the architecture defines its own copy_user_highpage(), so some bit=
rot has occurred.  ARM is currently fixing this, and MIPS will need to do t=
he same.
>=20
> (We can't use copy_user_highpage() in DAX because we don't necessarily ha=
ve a struct page for 'from'.)

Has there been any progress on this?  It would be unpleasant to merge
DAX into 3.19 and break MIPS and ARM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
