Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 023C76B0005
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 22:11:22 -0500 (EST)
Received: by mail-ig0-f178.google.com with SMTP id ik10so76368654igb.1
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 19:11:21 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id f188si8933410ioe.204.2016.02.02.19.11.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 Feb 2016 19:11:21 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/hugetlb: fix gigantic page initialization/allocation
Date: Wed, 3 Feb 2016 03:01:41 +0000
Message-ID: <20160203030137.GA22446@hori1.linux.bs1.fc.nec.co.jp>
References: <1454452420-25007-1-git-send-email-mike.kravetz@oracle.com>
 <alpine.DEB.2.10.1602021457500.9118@chino.kir.corp.google.com>
 <56B138F6.70704@oracle.com>
In-Reply-To: <56B138F6.70704@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <C5E51CC1DD83ED49A1703B43095E9CEA@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: David Rientjes <rientjes@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Jerome Marchand <jmarchan@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>

On Tue, Feb 02, 2016 at 03:17:10PM -0800, Mike Kravetz wrote:
> On 02/02/2016 02:59 PM, David Rientjes wrote:
> > On Tue, 2 Feb 2016, Mike Kravetz wrote:
> >=20
> >> Attempting to preallocate 1G gigantic huge pages at boot time with
> >> "hugepagesz=3D1G hugepages=3D1" on the kernel command line will preven=
t
> >> booting with the following:
> >>
> >> kernel BUG at mm/hugetlb.c:1218!
> >>
> >> When mapcount accounting was reworked, the setting of compound_mapcoun=
t_ptr
> >> in prep_compound_gigantic_page was overlooked.  As a result, the valid=
ation
> >> of mapcount in free_huge_page fails.
> >>
> >> The "BUG_ON" checks in free_huge_page were also changed to "VM_BUG_ON_=
PAGE"
> >> to assist with debugging.
> >>
> >> Fixes: af5642a8af ("mm: rework mapcount accounting to enable 4k mappin=
g of THPs")
> >> Suggested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> >> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> >=20
> > I'm not sure whether this should have a "From: Naoya Horiguchi" line wi=
th=20
> > an accompanying sign-off or not, since Naoya debugged and wrote the act=
ual=20
> > fix to prep_compound_gigantic_page().
>=20
> I agree.  Naoya did debug and provide fix via e-mail exchange.  He did no=
t
> sign-off and I could not tell if he was going to pursue.  My only intenti=
on
> was to fix ASAP.
>=20
> More than happy to give Naoya credit.

Thank you! It's great if you append my signed-off below yours.

Naoya=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
